class_name ToolManager
extends RefCounted

signal tool_application_started()
signal tool_application_failed()
signal tool_application_completed()

var tools:Array[ToolData]

var tool_deck:ToolDeck
var selected_tool_index:int = -1
var selected_tool:ToolData: get = _get_selected_tool

var _tool_applier:ToolApplier = ToolApplier.new()

func _init(initial_tools:Array[ToolData]) -> void:
	tools = initial_tools.duplicate()
	tool_deck = ToolDeck.new(initial_tools)
	_tool_applier.tool_application_started.connect(func(): tool_application_started.emit())
	_tool_applier.tool_application_failed.connect(func(): tool_application_failed.emit())
	_tool_applier.tool_application_completed.connect(func(): tool_application_completed.emit(selected_tool))

func draw_cards(count:int, gui_main_game:GUIMainGame) -> void:
	var _display_index = tool_deck.hand.size() - 1
	# _gui_bingo_main._gui_bingo_ball_hand.show()
	# var player_draw_results:Array[BingoBallData] = _player.draw_balls(number_to_draw)
	# await _gui_bingo_main.gui_animation_container.animate_draw(player_draw_results)
	# _gui_bingo_main._gui_bingo_ball_hand.add_balls(player_draw_results)
	# if player_draw_results.size() < number_to_draw:
	# 	# If no sufficient balls in draw pool, shuffle discard pile and draw again.
	# 	await shuffle()
	# 	var second_draw_result := _player.draw_balls(number_to_draw - player_draw_results.size())
	# 	await _gui_bingo_main.gui_animation_container.animate_draw(second_draw_result)
	# 	_gui_bingo_main._gui_bingo_ball_hand.add_balls(second_draw_result)
	# _draw_player_card_finished.emit()

func select_tool(index:int) -> void:
	selected_tool_index = index

func apply_tool(main_game:MainGame, field:Field) -> void:
	_tool_applier.apply_tool(main_game, field, selected_tool, selected_tool_index)

func _get_selected_tool() -> ToolData:
	if selected_tool_index < 0:
		return null
	return tools[selected_tool_index]
