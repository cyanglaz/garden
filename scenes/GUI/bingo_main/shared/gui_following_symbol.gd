class_name GUIFollowingSymbol
extends GUISymbol

var current_symbol_space:int = -1

var _gui_bingo_board:GUIBingoBoard: get = _get_gui_bingo_board
var _weak_bingo_board:WeakRef = weakref(null)
var available_space_indexes:Array = []

func bind_bingo_board(bingo_board:GUIBingoBoard) -> void:
	_weak_bingo_board = weakref(bingo_board)

func _process(_delta:float) -> void:
	var spaces:Array = _gui_bingo_board.get_spaces()
	for space:GUIBingoSpace in spaces:
		if !available_space_indexes.has(space._space_data.index):
			continue
		if space.get_global_rect().has_point(get_global_mouse_position()):
			global_position = space.global_position
			current_symbol_space = space._space_data.index
			return
	global_position = get_global_mouse_position() - size/2
	current_symbol_space = -1

func _get_gui_bingo_board() -> GUIBingoBoard:
	return _weak_bingo_board.get_ref()
