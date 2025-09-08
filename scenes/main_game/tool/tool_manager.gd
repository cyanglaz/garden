class_name ToolManager
extends RefCounted

const IN_USE_PAUSE := 0.2

signal tool_application_started(tool_data:ToolData)
signal tool_application_completed(tool_data:ToolData)
signal _apply_card_animation_completed()
signal _apply_animation_completed()

var tool_deck:Deck
var selected_tool_index:int: get = _get_selected_tool_index
var selected_tool:ToolData

var _gui_tool_card_container:GUIToolCardContainer: get = _get_gui_tool_card_container
var _tool_applier:ToolApplier = ToolApplier.new()
var _apply_animation_started:bool = false
var _apply_card_animation_started:bool = false
var _weak_gui_tool_card_container:WeakRef = weakref(null)

func _init(initial_tools:Array, gui_tool_card_container:GUIToolCardContainer) -> void:
	tool_deck = Deck.new(initial_tools)
	_apply_card_animation_completed.connect(_on_apply_card_animation_completed)
	_apply_animation_completed.connect(_on_apply_animation_completed)
	_weak_gui_tool_card_container = weakref(gui_tool_card_container)

func refresh_deck() -> void:
	tool_deck.refresh()

func cleanup_deck() -> void:
	tool_deck.filter_items(func(tool_data:ToolData): return !tool_data.rarity != -1)

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
	tool_deck.discard(tools)
	await _gui_tool_card_container.animate_discard(tools)

func use_card(tool_data:ToolData) -> void:
	tool_deck.use(tool_data)
	await _gui_tool_card_container.animate_use_card(tool_data)

func select_tool(tool_data:ToolData) -> void:
	selected_tool = tool_data

func apply_tool(main_game:MainGame, fields:Array, field_index:int) -> void:
	var applying_tool = selected_tool
	_handle_card(applying_tool)
	_run_apply_tool(main_game, fields, field_index, applying_tool)
	tool_application_started.emit(applying_tool)

func discardable_cards() -> Array:
	return tool_deck.hand.duplicate().filter(func(tool_data:ToolData): return tool_data != selected_tool)

func add_tool_to_deck(tool_data:ToolData) -> void:
	tool_deck.add_item(tool_data)

func add_tool_to_draw_pile(tool_data:ToolData, from_global_position:Vector2, random_place:bool, pause:bool) -> void:
	await _gui_tool_card_container.animate_add_card_to_draw_pile(tool_data, from_global_position, pause)
	tool_deck.add_temp_item_to_draw_pile(tool_data, random_place)

func get_tool(index:int) -> ToolData:
	return tool_deck.get_item(index)

func _handle_card(tool_data:ToolData) -> void:
	_apply_card_animation_started = true
	if !tool_data.need_select_field:
		await use_card(tool_data)
	await discard_cards([tool_data])
	_apply_card_animation_started = false
	_apply_card_animation_completed.emit()

func _run_apply_tool(main_game:MainGame, fields:Array, field_index:int, tool_data:ToolData) -> void:
	_apply_animation_started = true
	await main_game.field_container.trigger_tool_application_hook()
	await _tool_applier.apply_tool(main_game, fields, field_index, tool_data)
	_apply_animation_started = false
	_apply_animation_completed.emit()

func _get_selected_tool_index() -> int:
	if !selected_tool:
		return -1
	return tool_deck.hand.find(selected_tool)

func _get_gui_tool_card_container() -> GUIToolCardContainer:
	return _weak_gui_tool_card_container.get_ref()

func _on_apply_card_animation_completed() -> void:
	assert(!_apply_card_animation_started)
	if !_apply_animation_started:
		tool_application_completed.emit()

func _on_apply_animation_completed() -> void:
	assert(!_apply_animation_started)
	if !_apply_card_animation_started:
		tool_application_completed.emit()
