class_name ToolManager
extends RefCounted

signal tool_application_started(index:int)
signal tool_application_failed(index:int)
signal tool_application_completed(index:int)

var tool_deck:Deck
var selected_tool_index:int = -1
var selected_tool:ToolData: get = _get_selected_tool

var _tool_applier:ToolApplier = ToolApplier.new()

func _init(initial_tools:Array) -> void:
	tool_deck = Deck.new(initial_tools)
	_tool_applier.tool_application_started.connect(func(index:int): tool_application_started.emit(index))
	_tool_applier.tool_application_failed.connect(func(index:int): tool_application_failed.emit(index))
	_tool_applier.tool_application_completed.connect(func(index:int): tool_application_completed.emit(index))

func draw_cards(count:int, gui_tool_card_container:GUIToolCardContainer) -> void:
	var _display_index = tool_deck.hand.size() - 1
	var draw_results:Array = tool_deck.draw(count)
	await gui_tool_card_container.animate_draw(draw_results)
	# gui_tool_card_container.setup_with_tool_datas(tool_deck.hand)
	if draw_results.size() < count:
		# If no sufficient cards in draw pool, shuffle discard pile and draw again.
		await shuffle(gui_tool_card_container)
		var second_draw_result:Array = tool_deck.draw(count - draw_results.size())
		await gui_tool_card_container.animate_draw(second_draw_result)
		# gui_tool_card_container.setup_with_tool_datas(tool_deck.hand)

func shuffle(gui_tool_card_container:GUIToolCardContainer) -> void:
	var discard_pile_balls := tool_deck.discard_pool.duplicate()
	await gui_tool_card_container.animate_shuffle(discard_pile_balls)
	tool_deck.shuffle_draw_pool()

func discard_cards(indices:Array, gui_tool_card_container:GUIToolCardContainer) -> void:
	tool_deck.discard(indices)
	await gui_tool_card_container.animate_discard(indices)
	# gui_tool_card_container.setup_with_tool_datas(tool_deck.hand)

func select_tool(index:int) -> void:
	selected_tool_index = index

func apply_tool(main_game:MainGame, field:Field) -> void:
	var tool := selected_tool.get_duplicate()
	var index := selected_tool_index
	select_tool(-1)
	await _tool_applier.apply_tool(main_game, field, tool, index)

func get_tool(index:int) -> ToolData:
	return tool_deck.get_item(index)

func _get_selected_tool() -> ToolData:
	if selected_tool_index < 0:
		return null
	return tool_deck.get_item(selected_tool_index)
