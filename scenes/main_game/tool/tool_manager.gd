class_name ToolManager
extends RefCounted

const IN_USE_PAUSE := 0.2

signal tool_application_started(tool_data:ToolData)
signal tool_application_completed(tool_data:ToolData)
signal _discard_animation_completed(tool_datas:Array)
signal _tool_applied(tool_data:ToolData)

var tool_deck:Deck
var selected_tool_index:int = -1
var selected_tool:ToolData: get = _get_selected_tool

var _gui_tool_card_container:GUIToolCardContainer: get = _get_gui_tool_card_container
var _tool_applier:ToolApplier = ToolApplier.new()
var _applying_discard_tools := []
var _applying_tools := []
var _applying_started_tools := []
var _weak_gui_tool_card_container:WeakRef = weakref(null)

func _init(initial_tools:Array, gui_tool_card_container:GUIToolCardContainer) -> void:
	tool_deck = Deck.new(initial_tools)
	_discard_animation_completed.connect(_on_discard_animation_completed)
	_tool_applied.connect(_on_tool_applied)
	_weak_gui_tool_card_container = weakref(gui_tool_card_container)

func refresh_deck() -> void:
	tool_deck.refresh()

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
	var indices:Array = []
	for tool_data:ToolData in tools:
		var index:int = tool_deck.hand.find(tool_data)
		assert(index >= 0)
		indices.append(index)
	# Order is important, discard first, then animate
	tool_deck.discard(tools)
	await _gui_tool_card_container.animate_discard(indices)
	_discard_animation_completed.emit(tools)

func select_tool(index:int) -> void:
	selected_tool_index = index

func apply_tool(main_game:MainGame, fields:Array, selected_index:int) -> void:
	var applying_tool = selected_tool
	_applying_started_tools.append(applying_tool)
	tool_deck.use(applying_tool)
	_gui_tool_card_container.get_card(selected_tool_index).card_state = GUIToolCardButton.CardState.IN_USE
	tool_application_started.emit(applying_tool)
	await main_game.field_container.trigger_tool_application_hook()
	_applying_discard_tools.append(applying_tool)
	_applying_tools.append(applying_tool)
	if !applying_tool.need_select_field:
		_apply_non_field_tool(main_game, applying_tool)
	else:
		_apply_tool_to_field(main_game, applying_tool, fields, selected_index)
	discard_cards([applying_tool])

func discardable_cards() -> Array:
	return tool_deck.hand.duplicate().filter(func(tool_data:ToolData): return tool_data != selected_tool)

func add_tool_to_deck(tool_data:ToolData) -> void:
	tool_deck.add_item(tool_data)

func add_tool_to_draw_pile(tool_data:ToolData, from_global_position:Vector2, random_place:bool, pause:bool) -> void:
	await _gui_tool_card_container.animate_add_card_to_draw_pile(tool_data, from_global_position, pause)
	tool_deck.add_temp_item_to_draw_pile(tool_data, random_place)

func get_tool(index:int) -> ToolData:
	return tool_deck.get_item(index)

func _apply_non_field_tool(main_game:MainGame, applying_tool:ToolData) -> void:
	await _tool_applier.apply_tool(main_game, [], -1, applying_tool)
	_tool_applied.emit(applying_tool)

func _apply_tool_to_field(main_game:MainGame, applying_tool:ToolData, fields:Array, selected_index:int) -> void:
	await _tool_applier.apply_tool(main_game, fields, selected_index, applying_tool)
	_tool_applied.emit(applying_tool)

func _get_selected_tool() -> ToolData:
	if selected_tool_index < 0:
		return null
	return tool_deck.get_item(selected_tool_index)

func _get_gui_tool_card_container() -> GUIToolCardContainer:
	return _weak_gui_tool_card_container.get_ref()

func _on_discard_animation_completed(tool_datas:Array) -> void:
	if tool_datas.size() != 1:
		# This only handles when the discarding is from applying card
		# Multiple card discarding is ignored
		return
	var tool_data:ToolData = tool_datas.front()
	_applying_discard_tools.erase(tool_data)
	if !_applying_tools.has(tool_data) && !_applying_discard_tools.has(tool_data) && _applying_started_tools.has(tool_data):
		_applying_started_tools.erase(tool_data)
		tool_application_completed.emit()

func _on_tool_applied(tool_data:ToolData) -> void:
	_applying_tools.erase(tool_data)
	if !_applying_tools.has(tool_data) && !_applying_discard_tools.has(tool_data) && _applying_started_tools.has(tool_data):
		_applying_started_tools.erase(tool_data)
		tool_application_completed.emit()
