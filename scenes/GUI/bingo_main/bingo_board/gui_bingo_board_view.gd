class_name GUIBingoBoardDisplay
extends Control

@onready var _gui_overlay_background: ColorRect = %GUIOverlayBackground
@onready var _gui_bingo_board: GUIBingoBoard = $GUIBingoBoard

var _weak_bingo_board:WeakRef = weakref(null)

func _ready() -> void:
	_gui_overlay_background.gui_input.connect(_on_overlay_background_gui_input)

func bind_bingo_board(bingo_board:BingoBoard) -> void:
	_weak_bingo_board = weakref(bingo_board)

func animate_show() -> void:
	PauseManager.try_pause()
	var copied_spaces:Array[BingoSpaceData] = []
	for space_data:BingoSpaceData in _weak_bingo_board.get_ref().board:
		copied_spaces.append(space_data.get_duplicate())
	_gui_bingo_board.refresh_guis()
	_gui_bingo_board.refresh_with_board(copied_spaces, false)
	show()

func animated_hide() -> void:
	PauseManager.try_unpause()
	hide()

func _on_overlay_background_gui_input(event:InputEvent) -> void:
	if event.is_action_pressed("select"):
		animated_hide()

func _get_bingo_board() -> BingoBoard:
	return _weak_bingo_board.get_ref()
