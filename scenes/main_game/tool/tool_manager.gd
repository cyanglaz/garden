class_name ToolManager
extends RefCounted

const IN_USE_PAUSE := 0.2

enum ToolManagerState {
	IDLE,
	APPLYING_TURN_END_TOOL,
}

signal tool_application_started(tool_data:ToolData)
signal tool_application_completed(tool_data:ToolData)
signal tool_application_error(tool_data:ToolData, warning_type:WarningManager.WarningType)
signal hand_updated(hand:Array)
signal _tool_lifecycle_completed(tool_data:ToolData, combat_main:CombatMain)
signal _tool_actions_completed(tool_data:ToolData, combat_main:CombatMain)
signal _all_turn_end_cards_completed()

var tool_deck:Deck
var selected_tool_index:int: get = _get_selected_tool_index
var selected_tool:ToolData
var is_applying_tool:bool = false
var number_of_card_used_this_turn:int = 0
var card_use_limit_reached:bool = false: set = _set_card_use_limit_reached

var _gui_tool_card_container:GUIToolCardContainer: get = _get_gui_tool_card_container
var _tool_applier:ToolApplier = ToolApplier.new()
var _tool_application_queue:Array[ToolData] = []
var _tool_actions_queue:Array[ToolData] = []
var _tool_lifecycle_queue:Array[ToolData] = []

var _turn_end_cards_queue:Array = []

var _state:ToolManagerState = ToolManagerState.IDLE

var _weak_gui_tool_card_container:WeakRef = weakref(null)

func _init(initial_tools:Array, gui_tool_card_container:GUIToolCardContainer) -> void:
	tool_deck = Deck.new(initial_tools)
	tool_deck.hand_updated.connect(func() -> void: hand_updated.emit(tool_deck.hand))
	_weak_gui_tool_card_container = weakref(gui_tool_card_container)
	_tool_lifecycle_completed.connect(_on_tool_lifecycle_completed)
	_tool_actions_completed.connect(_on_tool_actions_completed)

func refresh_deck() -> void:
	tool_deck.refresh()
	for tool_data in tool_deck.pool:
		tool_data.refresh_for_level()

func cleanup_for_turn() -> void:
	number_of_card_used_this_turn = 0
	card_use_limit_reached = false

func draw_cards(count:int) -> Array:
	var _display_index = tool_deck.hand.size() - 1
	var draw_results:Array = tool_deck.draw(count)
	await _gui_tool_card_container.animate_draw(draw_results)
	if draw_results.size() < count:
		# If no sufficient cards in draw pool, shuffle discard pile and draw again.
		await shuffle()
		var second_draw_result:Array = tool_deck.draw(count - draw_results.size())
		await _gui_tool_card_container.animate_draw(second_draw_result)
		draw_results.append_array(second_draw_result)
	return draw_results

func shuffle() -> void:
	var discard_pile := tool_deck.discard_pool.duplicate()
	await _gui_tool_card_container.animate_shuffle(discard_pile)
	tool_deck.shuffle_draw_pool()

func trigger_turn_end_cards(combat_main:CombatMain) -> void:
	_state = ToolManagerState.APPLYING_TURN_END_TOOL
	_turn_end_cards_queue = tool_deck.hand.duplicate().filter(func(tool_data:ToolData): return tool_data.specials.has(ToolData.Special.NIGHTFALL))
	if _turn_end_cards_queue.is_empty():
		return
	_trigger_next_turn_end_card(combat_main)
	await _all_turn_end_cards_completed
	_state = ToolManagerState.IDLE
			
func discard_cards(tools:Array) -> void:
	assert(tools.size() > 0)
	# Order is important, discard first, then animate
	for tool_data in tools:
		tool_data.refresh_for_turn()
		if tool_data.back_card:
			tool_data.back_card.refresh_for_turn()
	tool_deck.discard(tools)
	await _gui_tool_card_container.animate_discard(tools)

func exhaust_cards(tools:Array) -> void:
	assert(tools.size() > 0)
	# Order is important, exhaust first, then animate
	tool_deck.exhaust(tools)
	await _gui_tool_card_container.animate_exhaust(tools)

func use_card(tool_data:ToolData) -> void:
	tool_deck.use(tool_data)
	await _gui_tool_card_container.animate_use_card(tool_data)

func select_tool(tool_data:ToolData) -> void:
	selected_tool = tool_data

func apply_tool(combat_main:CombatMain) -> void:
	is_applying_tool = true
	var applying_tool = selected_tool
	var number_of_cards_to_select := applying_tool.get_number_of_secondary_cards_to_select()
	var random := applying_tool.get_is_random_secondary_card_selection()
	var secondary_card_datas:Array = []
	if number_of_cards_to_select > 0:
		var selecting_from_cards = _get_secondary_cards_to_select_from(applying_tool)
		var actual_number_of_cards_to_select = mini(number_of_cards_to_select, selecting_from_cards.size())
		if actual_number_of_cards_to_select < number_of_cards_to_select:
			if applying_tool.get_card_selection_type() == ActionData.CardSelectionType.RESTRICTED:
				_gui_tool_card_container.animate_card_error_shake(applying_tool)
				tool_application_error.emit(applying_tool, applying_tool.get_card_selection_custom_error_message())
				is_applying_tool = false
				return
		else:
			if random:
				secondary_card_datas = Util.unweighted_roll(selecting_from_cards, mini(actual_number_of_cards_to_select, selecting_from_cards.size()))
			else:
				# Some actions need to select cards, for example discard, compost
				secondary_card_datas = await _gui_tool_card_container.select_secondary_cards(actual_number_of_cards_to_select, selecting_from_cards)
	number_of_card_used_this_turn += 1
	_tool_application_queue.append(applying_tool)
	tool_application_started.emit(applying_tool)
	_run_card_lifecycle(applying_tool, combat_main)
	_run_card_actions(combat_main, applying_tool, secondary_card_datas)

func discardable_cards() -> Array:
	return tool_deck.hand.duplicate().filter(func(tool_data:ToolData): return tool_data != selected_tool)

func add_tool_to_deck(tool_data:ToolData) -> void:
	tool_deck.add_item(tool_data)

func add_tools_to_draw_pile(tool_datas:Array, from_global_position:Vector2, random_place:bool, pause:bool) -> void:
	await _gui_tool_card_container.animate_add_cards_to_draw_pile(tool_datas, from_global_position, pause)
	tool_deck.add_items_to_draw_pile(tool_datas, random_place)
	for tool_data in tool_datas:
		tool_data.adding_to_deck_finished.emit()

func add_tools_to_discard_pile(tool_datas:Array, from_global_position:Vector2, pause:bool) -> void:
	await _gui_tool_card_container.animate_add_cards_to_discard_pile(tool_datas, from_global_position, pause)
	tool_deck.add_items_discard_pile(tool_datas)
	for tool_data in tool_datas:
		tool_data.adding_to_deck_finished.emit()

func add_tools_to_hand(tool_datas:Array, from_global_position:Vector2, pause:bool) -> void:
	tool_deck.add_items_to_hand(tool_datas)
	await _gui_tool_card_container.animate_add_cards_to_hand(tool_deck.hand, tool_datas, from_global_position, pause)
	for tool_data in tool_datas:
		tool_data.adding_to_deck_finished.emit()

func update_tool_card(tool_data:ToolData, new_tool_data:ToolData) -> void:
	var old_rarity = tool_data.rarity
	var front_card := tool_data.front_card
	var back_card := tool_data.back_card
	tool_data.copy(new_tool_data)
	tool_data.front_card = front_card
	tool_data.back_card = back_card
	_gui_tool_card_container.find_card(tool_data).animated_transform(old_rarity)

func get_tool(index:int) -> ToolData:
	return tool_deck.get_item(index)

func refresh_ui() -> void:
	_gui_tool_card_container.refresh_tool_cards()

func _run_card_lifecycle(tool_data:ToolData, combat_main:CombatMain) -> void:
	_tool_lifecycle_queue.append(tool_data)
	await _finish_card(tool_data)
	_tool_lifecycle_queue.erase(tool_data)
	_tool_lifecycle_completed.emit(tool_data, combat_main)

func _finish_card(tool_data:ToolData) -> void:
	if tool_data.specials.has(ToolData.Special.COMPOST):
		await exhaust_cards([tool_data])
	else:
		await discard_cards([tool_data])

func _run_card_actions(combat_main:CombatMain, tool_data:ToolData, secondary_card_datas:Array) -> void:
	_tool_actions_queue.append(tool_data)
	await combat_main.plant_field_container.trigger_tool_application_hook()
	await _tool_applier.apply_tool(combat_main, tool_data, secondary_card_datas, null)
	_tool_actions_queue.erase(tool_data)
	_tool_actions_completed.emit(tool_data, combat_main)

func _get_secondary_cards_to_select_from(tool_data:ToolData) -> Array:
	var selecting_from_cards:Array = []
	for card in _gui_tool_card_container.get_all_cards():
		if card.tool_data != tool_data:
			selecting_from_cards.append(card.tool_data)
	selecting_from_cards.erase(tool_data)
	if tool_data.tool_script && tool_data.tool_script.secondary_card_selection_filter():
		var filter:Callable = tool_data.tool_script.secondary_card_selection_filter()
		selecting_from_cards = selecting_from_cards.filter(filter)
	return selecting_from_cards

func _handle_tool_application_completed(tool_data:ToolData, combat_main:CombatMain) -> void:
	_tool_application_queue.erase(tool_data)
	if tool_data.tool_script:
		await tool_data.tool_script.handle_post_application_hook(tool_data, combat_main)
	tool_application_completed.emit(tool_data)
	is_applying_tool = false
	if _state == ToolManagerState.APPLYING_TURN_END_TOOL:
		_trigger_next_turn_end_card(combat_main)

func _trigger_next_turn_end_card(combat_main:CombatMain) -> void:
	if _turn_end_cards_queue.is_empty():
		_all_turn_end_cards_completed.emit()
		return
	var next_tool_data:ToolData = _turn_end_cards_queue.pop_back()
	select_tool(next_tool_data)
	apply_tool(combat_main)

#region events

func _on_tool_lifecycle_completed(tool_data:ToolData, combat_main:CombatMain) -> void:
	assert(!_tool_lifecycle_queue.has(tool_data))
	if !_tool_actions_queue.has(tool_data) && _tool_application_queue.has(tool_data):
		_handle_tool_application_completed(tool_data, combat_main)

func _on_tool_actions_completed(tool_data:ToolData, combat_main:CombatMain) -> void:
	assert(!_tool_actions_queue.has(tool_data))
	if !_tool_lifecycle_queue.has(tool_data) && _tool_application_queue.has(tool_data):
		_handle_tool_application_completed(tool_data, combat_main)

#endregion

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
