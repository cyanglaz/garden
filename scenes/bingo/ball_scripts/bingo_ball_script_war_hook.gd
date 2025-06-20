class_name BingoBallScriptWarHook
extends BingoBallScript

func _has_placement_events() -> bool:
	var column_spaces:Array = _get_empty_column_spaces()
	var all_ball_spaces_from_other_columns:= _get_all_ball_spaces_from_other_columns()
	return column_spaces.size() > 0 && all_ball_spaces_from_other_columns.size() > 0

func _handle_placement_events() -> void:
	var space_to_move_from = _get_random_ball_space_from_other_column()
	var space_to_move_to = _get_random_empty_space_from_column()
	await Singletons.game_main._bingo_controller.handle_move_balls([space_to_move_from], [space_to_move_to])
	_placed_on_board_event_finished.emit()

func _get_empty_column_spaces() -> Array:
	var column := BingoBoard.find_column(bingo_space_data.index)
	return bingo_board.board.filter(func(space:BingoSpaceData) -> bool:
		return space.ball_data == null && BingoBoard.find_column(space.index) == column
	)

func _get_all_ball_spaces_from_other_columns() -> Array:
	var column := BingoBoard.find_column(bingo_space_data.index)
	return bingo_board.board.filter(func(space:BingoSpaceData) -> bool:
		return space.ball_data != null && BingoBoard.find_column(space.index) != column
	)
	
func _get_random_ball_space_from_other_column() -> int:
	var all_ball_spaces_from_other_columns:= _get_all_ball_spaces_from_other_columns()
	assert(all_ball_spaces_from_other_columns.size() > 0)
	return Util.unweighted_roll(all_ball_spaces_from_other_columns, 1)[0].index

func _get_random_empty_space_from_column() -> int:
	var column_spaces:Array = _get_empty_column_spaces()
	assert(column_spaces.size() > 0)
	return Util.unweighted_roll(column_spaces, 1)[0].index
