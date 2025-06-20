class_name BingoBallScriptLowKick
extends BingoBallScript

func _has_placement_events() -> bool:
	var enemy_spaces := _get_enemies_not_on_row()
	return !enemy_spaces.is_empty()

func _handle_placement_events() -> void:
	var enemy_spaces := _get_enemies_not_on_row()
	assert(!enemy_spaces.is_empty())
	var random_enemy_space:BingoSpaceData = enemy_spaces.pick_random()

	var space_datas_in_row:Array = bingo_board.board.filter(func(space_data:BingoSpaceData) -> bool:
		return BingoBoard.find_row(space_data.index) == _get_row_index()
	)
	var empty_spaces_in_bottom_row:Array = space_datas_in_row.filter(func(space_data:BingoSpaceData) -> bool:
		return space_data.ball_data == null
	)
	if !empty_spaces_in_bottom_row.is_empty():
		var random_empty_space:BingoSpaceData = empty_spaces_in_bottom_row.pick_random()
		var from_indexes:Array = [random_enemy_space.index]
		var to_indexes:Array = [random_empty_space.index]
		await Singletons.game_main._bingo_controller.handle_move_balls(from_indexes, to_indexes)
	_placed_on_board_event_finished.emit()

func _get_row_index() -> int:
	return (_bingo_ball_data.data["row"] as int) - 1

func _get_enemies_not_on_row() -> Array:
	var enemy_spaces := bingo_board.board.filter(func(space_data:BingoSpaceData) -> bool:
		return space_data.ball_data && space_data.ball_data.team == BingoBallData.Team.ENEMY && BingoBoard.find_row(space_data.index) < _get_row_index()
	)
	return enemy_spaces
