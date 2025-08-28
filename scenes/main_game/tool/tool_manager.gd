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

func draw_cards(count:int, gui_tool_card_container:GUIToolCardContainer) -> Array:
	var _display_index = tool_deck.hand.size() - 1
	var draw_results:Array = tool_deck.draw(count)
	await gui_tool_card_container.animate_draw(draw_results)
	if draw_results.size() < count:
		# If no sufficient cards in draw pool, shuffle discard pile and draw again.
		await shuffle(gui_tool_card_container)
		var second_draw_result:Array = tool_deck.draw(count - draw_results.size())
		await gui_tool_card_container.animate_draw(second_draw_result)
		draw_results.append_array(second_draw_result)
	return draw_results

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
	# Order is important, discard first, then animate
	tool_deck.discard(tools)
	await gui_tool_card_container.animate_discard(indices)

func select_tool(index:int) -> void:
	selected_tool_index = index

func apply_tool(main_game:MainGame, fields:Array, selected_index:int, gui_tool_card_container:GUIToolCardContainer) -> void:
	var applying_tool = selected_tool
	var index:int = tool_deck.hand.find(applying_tool)
	await gui_tool_card_container.animate_use_card(index)
	tool_deck.use(applying_tool)
	tool_application_started.emit(applying_tool)
	await main_game.field_container.trigger_tool_application_hook()
	if !applying_tool.need_select_field:
		await _tool_applier.apply_tool(main_game, [], -1, applying_tool)
		tool_application_completed.emit(applying_tool)
	else:
		await _apply_tool_to_field(main_game, applying_tool, fields, selected_index)
	tool_deck.discard([applying_tool])
	await gui_tool_card_container.animate_discard_using_card()

func add_tool(tool_data:ToolData) -> void:
	tool_deck.add_item(tool_data)

func get_tool(index:int) -> ToolData:
	return tool_deck.get_item(index)

func _apply_tool_to_field(main_game:MainGame, applying_tool:ToolData, fields:Array, selected_index:int) -> void:
	await _tool_applier.apply_tool(main_game, fields, selected_index, applying_tool)
	tool_application_completed.emit(applying_tool)

func _get_selected_tool() -> ToolData:
	if selected_tool_index < 0:
		return null
	return tool_deck.get_item(selected_tool_index)
