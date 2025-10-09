class_name ToolManager
extends RefCounted

const IN_USE_PAUSE := 0.2

signal tool_application_started(tool_data:ToolData)
signal tool_application_completed(tool_data:ToolData)
signal _tool_lifecycle_completed(tool_data:ToolData)
signal _tool_actions_completed(tool_data:ToolData)

var tool_deck:Deck
var selected_tool_index:int: get = _get_selected_tool_index
var selected_tool:ToolData
var number_of_card_used_this_turn:int = 0
var card_use_limit_reached:bool = false: set = _set_card_use_limit_reached

var _gui_tool_card_container:GUIToolCardContainer: get = _get_gui_tool_card_container
var _tool_applier:ToolApplier = ToolApplier.new()
var _tool_application_queue:Array[ToolData] = []
var _tool_actions_queue:Array[ToolData] = []
var _tool_lifecycle_queue:Array[ToolData] = []

var _weak_gui_tool_card_container:WeakRef = weakref(null)

func _init(initial_tools:Array, gui_tool_card_container:GUIToolCardContainer) -> void:
	tool_deck = Deck.new(initial_tools)
	tool_deck.hand_updated.connect(_on_hand_updated)
	_weak_gui_tool_card_container = weakref(gui_tool_card_container)
	_tool_lifecycle_completed.connect(_on_tool_lifecycle_completed)
	_tool_actions_completed.connect(_on_tool_actions_completed)

func refresh_deck() -> void:
	tool_deck.refresh()
	for tool_data in tool_deck.pool:
		tool_data.refresh_for_level()

func cleanup_deck() -> void:
	tool_deck.cleanup_temp_items()

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
	await _gui_tool_card_container.animate_shuffle(discard_pile.size())
	tool_deck.shuffle_draw_pool()

func discard_cards(tools:Array) -> void:
	assert(tools.size() > 0)
	# Order is important, discard first, then animate
	for tool_data in tools:
		tool_data.refresh_for_turn()
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

func apply_tool(main_game:MainGame, fields:Array, field_index:int) -> void:
	number_of_card_used_this_turn += 1
	var applying_tool = selected_tool
	_run_card_lifecycle(applying_tool)
	_run_card_actions(main_game, fields, field_index, applying_tool)
	_tool_application_queue.append(applying_tool)
	tool_application_started.emit(applying_tool)

func discardable_cards() -> Array:
	return tool_deck.hand.duplicate().filter(func(tool_data:ToolData): return tool_data != selected_tool)

func add_tool_to_deck(tool_data:ToolData) -> void:
	tool_deck.add_item(tool_data)

func add_temp_tools_to_draw_pile(tool_datas:Array[ToolData], from_global_position:Vector2, random_place:bool, pause:bool) -> void:
	await _gui_tool_card_container.animate_add_cards_to_draw_pile(tool_datas, from_global_position, pause)
	tool_deck.add_temp_items_to_draw_pile(tool_datas, random_place)

func add_temp_tools_to_discard_pile(tool_datas:Array[ToolData], from_global_position:Vector2, pause:bool) -> void:
	await _gui_tool_card_container.animate_add_cards_to_discard_pile(tool_datas, from_global_position, pause)
	tool_deck.add_temp_items_to_discard_pile(tool_datas)

func add_temp_tools_to_hand(tool_datas:Array[ToolData], from_global_position:Vector2, pause:bool) -> void:
	tool_deck.add_temp_items_to_hand(tool_datas)
	await _gui_tool_card_container.animate_add_cards_to_hand(tool_deck.hand, tool_datas, from_global_position, pause)

func get_tool(index:int) -> ToolData:
	return tool_deck.get_item(index)

func finish_card(tool_data:ToolData) -> void:
	if tool_data.specials.has(ToolData.Special.COMPOST):
		await exhaust_cards([tool_data])
	else:
		await discard_cards([tool_data])

func refresh_ui() -> void:
	_gui_tool_card_container.refresh_tool_cards()

func _run_card_lifecycle(tool_data:ToolData) -> void:
	_tool_lifecycle_queue.append(tool_data)
	if tool_data.specials.has(ToolData.Special.COMPOST):
		await exhaust_cards([tool_data])
	else:
		await discard_cards([tool_data])
	_tool_lifecycle_queue.erase(tool_data)
	_tool_lifecycle_completed.emit(tool_data)

func _run_card_actions(main_game:MainGame, fields:Array, field_index:int, tool_data:ToolData) -> void:
	_tool_actions_queue.append(tool_data)
	await main_game.field_container.trigger_tool_application_hook()
	await _tool_applier.apply_tool(main_game, fields, field_index, tool_data, null)
	_tool_actions_queue.erase(tool_data)
	_tool_actions_completed.emit(tool_data)

#region events

func _on_tool_lifecycle_completed(tool_data:ToolData) -> void:
	assert(!_tool_lifecycle_queue.has(tool_data))
	if !_tool_lifecycle_queue.has(tool_data) && _tool_application_queue.has(tool_data):
		_tool_application_queue.erase(tool_data)
		tool_application_completed.emit(tool_data)

func _on_tool_actions_completed(tool_data:ToolData) -> void:
	assert(!_tool_actions_queue.has(tool_data))
	if !_tool_actions_queue.has(tool_data) && _tool_application_queue.has(tool_data):
		_tool_application_queue.erase(tool_data)
		tool_application_completed.emit(tool_data)

func _on_hand_updated() -> void:
	for tool_data in tool_deck.hand:
		tool_data.request_refresh.emit()

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
