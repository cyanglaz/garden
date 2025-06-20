class_name GUIOverlayMain
extends Control

signal new_ball_selected(bingo_ball_data:BingoBallData)
signal action_selected(action_data:ActionData)
signal action_selection_finished()

@onready var _gui_action_main: GUIActionMain = $GUIActionMain
@onready var _gui_card_reward_main: GUICardRewardMain = $GUICardRewardMain
@warning_ignore("unused_private_class_variable")
@onready var _gui_forge_main: GUIForgeMain = %GUIForgeMain
@warning_ignore("unused_private_class_variable")
@onready var _gui_attune_main: GUIAttuneMain = %GUIAttuneMain
@onready var _gui_all_deck_display: GUIAllDeckDisplay = %GUIAllDeckDisplay
@onready var _gui_bingo_board_view: GUIBingoBoardDisplay = %GUIBingoBoardView
@onready var _top_view_container: Control = %TopViewContainer

func _ready() -> void:
	_gui_action_main.action_selected.connect(func(action:ActionData):action_selected.emit(action))
	_gui_action_main.action_selection_finished.connect(func():action_selection_finished.emit())
	_gui_card_reward_main.card_reward_finished.connect(func(bingo_ball_data:BingoBallData):new_ball_selected.emit(bingo_ball_data))

func add_child_to_top_view(child:Control) -> void:
	_top_view_container.add_child(child)

func bind_game_main(game_main:GameMain) -> void:
	_gui_action_main.bind_player(game_main._player)
	_gui_bingo_board_view.bind_bingo_board(game_main._bingo_board)

func animate_show_actions() -> void:
	_clear_top_view_children()
	_gui_action_main.animate_show()
	_make_view_to_top(_gui_action_main)

func animate_show_forge_main(bingo_ball_datas:Array[BingoBallData]) -> void:
	_clear_top_view_children()
	_make_view_to_top(_gui_forge_main)
	await _gui_forge_main.animate_show_with_balls(bingo_ball_datas)

func animate_show_attune_main(bingo_ball_datas:Array[BingoBallData]) -> void:
	_clear_top_view_children()
	_make_view_to_top(_gui_attune_main)
	await _gui_attune_main.animate_show_with_balls(bingo_ball_datas)

func animate_show_upgrade_main(bingo_ball_datas:Array[BingoBallData]) -> void:
	_clear_top_view_children()
	_gui_card_reward_main.show_with_balls(bingo_ball_datas)
	_make_view_to_top(_gui_card_reward_main)

func toggle_all_deck_display(pool:Array[BingoBallData]) -> void:
	if _gui_all_deck_display.visible:
		_gui_all_deck_display.animate_hide()
	else:
		_clear_top_view_children()
		_hide_all_main_overlays()
		_gui_all_deck_display.show_with_pool(pool)
		_make_view_to_top(_gui_all_deck_display)

func toggle_bingo_board_view() -> void:
	if _gui_bingo_board_view.visible:
		_gui_bingo_board_view.animated_hide()
	else:
		_clear_top_view_children()
		_hide_all_main_overlays()
		_gui_bingo_board_view.animate_show()
		_make_view_to_top(_gui_bingo_board_view)

func _make_view_to_top(view:Control) -> void:
	# Move the view to to, but behind top_view_container
	move_child(view, get_child_count() - 2)

func _hide_all_main_overlays() -> void:
	if _gui_all_deck_display.visible:
		_gui_all_deck_display.animate_hide()
	if _gui_bingo_board_view.visible:
		_gui_bingo_board_view.animated_hide()

func _clear_top_view_children() -> void:
	Util.remove_all_children(_top_view_container)
