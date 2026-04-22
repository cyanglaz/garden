class_name ToolManager
extends RefCounted

signal tool_application_started(tool_data:ToolData)
signal tool_application_success(tool_data:ToolData)
signal tool_application_completed(tool_data:ToolData)
signal tool_application_error(tool_data:ToolData, error_message:String)
signal tool_application_bailed(tool_data:ToolData)
signal tools_drawn(tool_datas:Array)
signal tools_exhausted(tool_datas:Array)
signal hand_updated(hand:Array)
signal cards_removed_from_hand(tool_datas:Array, updated_hand:Array) # Triggers after the removal animation (discard or exhaust)
signal max_hand_size_reached()
signal pool_updated(pool:Array)

var tool_deck:Deck
var selected_tool_index:int: get = _get_selected_tool_index
var selected_tool:ToolData
var number_of_card_used_this_turn:int = 0
var card_use_limit_reached:bool = false: set = _set_card_use_limit_reached
var is_mid_turn:bool = false

var _gui_tool_card_container:GUIToolCardContainer: get = _get_gui_tool_card_container
var _tool_applier:ToolApplier = ToolApplier.new()

var _queued_tool_applications:Array[ToolData] = []

var _weak_gui_tool_card_container:WeakRef = weakref(null)

func _init(initial_tools:Array, gui_tool_card_container:GUIToolCardContainer) -> void:
	tool_deck = Deck.new(initial_tools)
	tool_deck.hand_updated.connect(func() -> void: hand_updated.emit(tool_deck.hand))
	tool_deck.pool_updated.connect(func(pool:Array) -> void: pool_updated.emit(pool))
	tool_deck.items_exhausted.connect(func(items:Array) -> void: tools_exhausted.emit(items))
	_weak_gui_tool_card_container = weakref(gui_tool_card_container)

func refresh_cards_ui(combat_main:CombatMain) -> void:
	for tool_data in tool_deck.pool:
		tool_data.refresh_ui(combat_main)

func cleanup_for_turn() -> void:
	number_of_card_used_this_turn = 0
	card_use_limit_reached = false

func draw_cards(count:int, first_turn_draw:bool, combat_main:CombatMain) -> Array:
	var _display_index = tool_deck.hand.size() - 1
	var draw_results:Array = []
	var random_draw_count := count
	if first_turn_draw:
		draw_results.append_array(tool_deck.draw_specific(func(tool_data:ToolData): return tool_data.specials.has(ToolData.Special.HANDY)))
		random_draw_count -= draw_results.size()
	var available_slots := Constants.MAX_HAND_SIZE - tool_deck.hand.size()
	var hand_size_limited := random_draw_count > available_slots
	if hand_size_limited:
		max_hand_size_reached.emit()
	random_draw_count = mini(random_draw_count, available_slots)
	draw_results.append_array(tool_deck.draw(random_draw_count))
	await _gui_tool_card_container.animate_draw(draw_results, combat_main)
	if draw_results.size() < random_draw_count:
		# If no sufficient cards in draw pool, shuffle discard pile and draw again.
		await shuffle(combat_main)
		var second_draw_result:Array = tool_deck.draw(random_draw_count - draw_results.size())
		await _gui_tool_card_container.animate_draw(second_draw_result, combat_main)
		draw_results.append_array(second_draw_result)
	tools_drawn.emit(draw_results)
	return draw_results

func shuffle(combat_main:CombatMain) -> void:
	var discard_pile := tool_deck.discard_pool.duplicate()
	await _gui_tool_card_container.animate_shuffle(discard_pile, combat_main)
	tool_deck.shuffle_draw_pool()

func trigger_turn_end_cards(combat_main:CombatMain) -> void:
	var end_turn_cards:Array = tool_deck.hand.duplicate().filter(func(tool_data:ToolData): return tool_data.specials.has(ToolData.Special.NIGHTFALL))
	if end_turn_cards.is_empty():
		return
	for tool_data in end_turn_cards:
		queue_apply_tool(combat_main, tool_data)
			
func discard_cards(tools:Array, combat_main:CombatMain) -> void:
	assert(tools.size() > 0)
	# Order is important, discard first, then animate
	for tool_data in tools:
		tool_data.refresh_for_turn()

	tool_deck.discard(tools)
	await _gui_tool_card_container.animate_discard(tools, combat_main)
	cards_removed_from_hand.emit(tools, tool_deck.hand)

func exhaust_cards(tools:Array, combat_main:CombatMain) -> void:
	assert(tools.size() > 0)
	# Order is important, exhaust first, then animate
	tool_deck.exhaust(tools)
	await _gui_tool_card_container.animate_exhaust(tools, combat_main)
	cards_removed_from_hand.emit(tools, tool_deck.hand)

func clear_tool_selection() -> void:
	selected_tool = null

func queue_apply_tool(combat_main:CombatMain, applying_tool:ToolData) -> void:
	if _queued_tool_applications.has(applying_tool):
		return
	_queued_tool_applications.append(applying_tool)
	_queue_tool_application_stages(combat_main, applying_tool)

func select_secondary_cards(number_of_cards:int, trigger_card:ToolData, filter:Callable) -> Array:
	var candidates:Array = tool_deck.hand.filter(filter)
	return await _gui_tool_card_container.select_secondary_cards(number_of_cards, trigger_card, candidates)

func add_tool_to_deck(tool_data:ToolData) -> void:
	tool_deck.add_item(tool_data)

func move_hand_card_to_top_of_draw_pile(tool_data: ToolData, combat_main:CombatMain) -> void:
	var from_pos := _gui_tool_card_container.find_card(tool_data).global_position
	tool_deck.move_to_draw_pile([tool_data], [0])
	await _gui_tool_card_container.animate_stash_card_to_draw_pile(tool_data, from_pos, combat_main)
	tool_data.adding_to_deck_finished.emit()

func add_tools_to_draw_pile(tool_datas:Array, from_global_position:Vector2, random_place:bool, pause:bool, combat_main:CombatMain) -> void:
	await _gui_tool_card_container.animate_add_cards_to_draw_pile(tool_datas, from_global_position, pause, combat_main)
	tool_deck.add_items_to_draw_pile(tool_datas, random_place)
	for tool_data in tool_datas:
		tool_data.adding_to_deck_finished.emit()

func add_tools_to_discard_pile(tool_datas:Array, from_global_position:Vector2, pause:bool, combat_main:CombatMain) -> void:
	await _gui_tool_card_container.animate_add_cards_to_discard_pile(tool_datas, from_global_position, pause, combat_main)
	tool_deck.add_items_discard_pile(tool_datas)
	for tool_data in tool_datas:
		tool_data.adding_to_deck_finished.emit()

func add_tools_to_hand(tool_datas:Array, from_global_position:Vector2, pause:bool, combat_main:CombatMain) -> void:
	tool_deck.add_items_to_hand(tool_datas)
	await _gui_tool_card_container.animate_add_cards_to_hand(tool_deck.hand, tool_datas, from_global_position, pause, combat_main)
	for tool_data in tool_datas:
		tool_data.adding_to_deck_finished.emit()

func update_tool_card(tool_data:ToolData, new_tool_data:ToolData) -> void:
	var old_rarity = tool_data.rarity
	if tool_data != new_tool_data:
		tool_data.copy(new_tool_data)
	_gui_tool_card_container.find_card(tool_data).animated_transform(old_rarity)

func get_tool(index:int) -> ToolData:
	return tool_deck.get_item(index)

func _run_card_lifecycle(tool_data:ToolData, combat_main:CombatMain) -> void:
	await _finish_card(tool_data, combat_main)

func _finish_card(tool_data:ToolData, combat_main:CombatMain) -> void:
	tool_data.remove_single_use_special_effects(combat_main)
	if tool_data.specials.has(ToolData.Special.COMPOST):
		await exhaust_cards([tool_data], combat_main)
	else:
		await discard_cards([tool_data], combat_main)

func _handle_tool_application_completed(tool_data:ToolData, combat_main:CombatMain) -> void:
	if tool_data.tool_script:
		await tool_data.tool_script.handle_post_application_hook(tool_data, combat_main)
	tool_application_completed.emit(tool_data)

func _queue_tool_application_stages(combat_main:CombatMain, applying_tool:ToolData) -> void:
	var stage_context := {
		"skip": false,
	}
	var pre_hook_request = CombatQueueRequest.new()
	pre_hook_request.callback = func(_cm: CombatMain) -> void: _run_tool_stage_start_and_pre_hook(combat_main, applying_tool, stage_context)
	Events.request_combat_queue_push.emit(pre_hook_request)

	_queue_tool_state_apply_actions(combat_main, applying_tool)

	var finish_request = CombatQueueRequest.new()
	finish_request.callback = func(_cm: CombatMain) -> void: await _run_tool_stage_finish(combat_main, applying_tool, stage_context)
	Events.request_combat_queue_push.emit(finish_request)

func _run_tool_stage_start_and_pre_hook(combat_main:CombatMain, tool_data:ToolData, stage_context:Dictionary) -> void:
	if !_can_execute_queued_tool(tool_data):
		stage_context["skip"] = true
		tool_application_bailed.emit(tool_data)
		return
	if !_tool_applier.can_tool_be_applied(tool_data, tool_deck.hand):
		tool_application_error.emit(tool_data, tool_data.get_card_selection_custom_error_message())
		stage_context["skip"] = true
		tool_application_bailed.emit(tool_data)
		return
	selected_tool = tool_data
	tool_application_started.emit(tool_data)
	combat_main.plant_field_container.queue_tool_application_hooks()
	combat_main.player.player_upgrades_manager.queue_pre_tool_application_hooks(combat_main, tool_data)
	_gui_tool_card_container.animate_card_use(tool_data)

func _queue_tool_state_apply_actions(combat_main:CombatMain, tool_data:ToolData) -> void:
	_tool_applier.queue_tool_application(combat_main, tool_data)

func _run_tool_stage_finish(combat_main:CombatMain, tool_data:ToolData, stage_context:Dictionary) -> void:
	var should_skip:bool = stage_context["skip"]
	_queued_tool_applications.erase(tool_data)
	if should_skip:
		return
	number_of_card_used_this_turn += 1
	tool_application_success.emit(tool_data)
	await _run_card_lifecycle(tool_data, combat_main)
	_handle_tool_application_completed(tool_data, combat_main)

func _can_execute_queued_tool(tool_data:ToolData) -> bool:
	if !tool_deck.hand.has(tool_data):
		return false
	if !_gui_tool_card_container:
		return false
	if !is_mid_turn && !tool_data.specials.has(ToolData.Special.NIGHTFALL):
		return false
	if tool_data.specials.has(ToolData.Special.NIGHTFALL) && is_mid_turn:
		return false
	return true

#region setters/getters

func _get_selected_tool_index() -> int:
	if !selected_tool:
		return -1
	return tool_deck.hand.find(selected_tool)

func _get_gui_tool_card_container() -> GUIToolCardContainer:
	return _weak_gui_tool_card_container.get_ref()

func _set_card_use_limit_reached(value:bool) -> void:
	card_use_limit_reached = value
	_gui_tool_card_container.card_use_limit_reached = value

#endregion
