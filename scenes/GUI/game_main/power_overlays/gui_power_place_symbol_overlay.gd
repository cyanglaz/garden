class_name GUIPowerPlaceSymbolOverlay
extends GUIPowerOverlay

signal eligible_space_clicked(power_data:BingoBallData, space_index:int)

@onready var _gui_following_symbol: GUIFollowingSymbol = %GUIFollowingSymbol

var _bingo_ball_data:BingoBallData

func _ready() -> void:
	super._ready()
	_cancel_button.mouse_entered.connect(_on_cancel_button_mouse_entered)
	_cancel_button.mouse_exited.connect(_on_cancel_button_mouse_exited)

func activate_with_ball_path(ball_path:String) -> void:
	assert(_active, "GUIPowerOverlay is not active")
	_bingo_ball_data = load(ball_path).get_duplicate()
	_bingo_ball_data.owner = Singletons.game_main._player
	_gui_following_symbol.bind_ball_data(_bingo_ball_data)
	_highlight_unavailable_spaces(_bingo_ball_data)
	
func bind_gui_bingo_board(gui_bingo_board:GUIBingoBoard) -> void:
	super.bind_gui_bingo_board(gui_bingo_board)
	_gui_following_symbol.bind_bingo_board(gui_bingo_board)

func _highlight_unavailable_spaces(bingo_ball_data:BingoBallData) -> void:
	var available_spaces:Array = _bingo_board.find_available_spaces(bingo_ball_data)
	_gui_following_symbol.available_space_indexes = available_spaces.map(func(space:BingoSpaceData) -> int:
		return space.index
	)
	for space:BingoSpaceData in available_spaces:
		space.gui_bingo_space.highlight = true
	_gui_following_symbol.show()

#region overrides

func _handle_select() -> void:
	var space_index:int = _gui_following_symbol.current_symbol_space
	if space_index < 0:
		return
	eligible_space_clicked.emit(_bingo_ball_data, space_index)

#endregion

func _on_cancel_button_mouse_entered() -> void:
	_gui_following_symbol.hide()

func _on_cancel_button_mouse_exited() -> void:
	_gui_following_symbol.show()
