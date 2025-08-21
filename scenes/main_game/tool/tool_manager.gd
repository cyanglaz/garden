class_name ToolManager
extends RefCounted

signal tool_application_started(tool_data:ToolData)
signal tool_application_completed(tool_data:ToolData)

var tool_deck:Deck
var selected_tool_index:int = -1
var selected_tool:ToolData: get = _get_selected_tool

var _tool_applier:ToolApplier = ToolApplier.new()

func _init(initial_tools:Array) -> void:
	tool_deck = Deck.new(initial_tools)

func refresh_deck() -> void:
	tool_deck.refresh()

func draw_cards(count:int, gui_tool_card_container:GUIToolCardContainer) -> void:
	var _display_index = tool_deck.hand.size() - 1
	var draw_results:Array = tool_deck.draw(count)
	await gui_tool_card_container.animate_draw(draw_results)
	if draw_results.size() < count:
		# If no sufficient cards in draw pool, shuffle discard pile and draw again.
		await shuffle(gui_tool_card_container)
		var second_draw_result:Array = tool_deck.draw(count - draw_results.size())
		await gui_tool_card_container.animate_draw(second_draw_result)

func shuffle(gui_tool_card_container:GUIToolCardContainer) -> void:
	var discard_pile := tool_deck.discard_pool.duplicate()
	await gui_tool_card_container.animate_shuffle(discard_pile.size())
	tool_deck.shuffle_draw_pool()

func discard_cards(tools:Array, gui_tool_card_container:GUIToolCardContainer) -> void:
	var indices:Array = []
	for tool_data:ToolData in tools:
		var index:int = tool_deck.hand.find(tool_data)
		assert(index >= 0)
		indices.append(index)
	await gui_tool_card_container.animate_discard(indices)
	tool_deck.discard(tools)

func select_tool(index:int) -> void:
	selected_tool_index = index

func apply_tool(main_game:MainGame, fields:Array) -> void:
	var applying_tool := selected_tool
	tool_application_started.emit(applying_tool)
	await main_game.field_container.trigger_tool_application_hook()
	if !applying_tool.need_select_field:
		await _tool_applier.apply_tool(main_game, null, applying_tool)
		tool_application_completed.emit(applying_tool)
	else:
		await _apply_tool_to_next_field(main_game, applying_tool, fields, 0)

func add_tool(tool_data:ToolData) -> void:
	tool_deck.add_item(tool_data)

func get_tool(index:int) -> ToolData:
	return tool_deck.get_item(index)

func _apply_tool_to_next_field(main_game:MainGame, applying_tool:ToolData, fields:Array, field_index:int) -> void:
	if field_index >= fields.size():
		tool_application_completed.emit(applying_tool)
		return
	var field:Field = fields[field_index]
	await _tool_applier.apply_tool(main_game, field, applying_tool)
	await _apply_tool_to_next_field(main_game, applying_tool, fields, field_index + 1)

func _get_selected_tool() -> ToolData:
	if selected_tool_index < 0:
		return null
	return tool_deck.get_item(selected_tool_index)
