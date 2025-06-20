class_name GUIPowerOverlay
extends Control

signal deactivated()

@warning_ignore("unused_private_class_variable")
@onready var _gui_bingo_board: GUIBingoBoard = %GUIBingoBoard
@onready var _cancel_button: GUIRichTextButton = %CancelButton

var _active:bool
var _bingo_board:BingoBoard

func _ready() -> void:
	_cancel_button.action_evoked.connect(_on_cancel_button_action_evoked)

func _input(event: InputEvent) -> void:
	if !_active:
		return
	if event.is_action_released("de-select"):
		_deactivate()
	elif event.is_action_released("select"):
		_handle_select()
	#	if current_symbol_space < 0:
	#		return
	#	clicked.emit(_ball_data, current_symbol_space)
	#	deactivate()
	#	current_symbol_space = -1

func bind_gui_bingo_board(gui_bingo_board:GUIBingoBoard) -> void:
	# Need to set the position deferred so that the gui_bingo_board is fully initialized
	_set_board_position.call_deferred(gui_bingo_board)

func activate(bingo_board:BingoBoard) -> void:
	_active = true
	_bingo_board = bingo_board.get_duplicate()
	_gui_bingo_board.refresh_with_board(_bingo_board.board, false)
	_handle_activate()

func _set_board_position(gui_bingo_board:GUIBingoBoard) -> void:
	_gui_bingo_board.global_position = gui_bingo_board.global_position

func _deactivate() -> void:
	_active = false
	_handle_deactivated()
	deactivated.emit()

#region For Overrides

func _handle_deactivated() -> void:
	pass

func _handle_activate() -> void:
	pass

func _handle_select() -> void:
	pass

#endregion

#region Getters and Setters

#endregion

func _on_cancel_button_action_evoked() -> void:
	_deactivate()
