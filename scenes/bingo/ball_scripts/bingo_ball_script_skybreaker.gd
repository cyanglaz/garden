class_name BingoBallScriptSkybreaker
extends BingoBallScript

func _has_placement_events() -> bool:
	var enemy_spaces_in_the_same_column:Array = _get_enemy_spaces_from_same_column()
	var destinations:Array = _get_destination_indexes_for_enemy_balls(enemy_spaces_in_the_same_column)
	return destinations.size() > 0

func _handle_placement_events() -> void:
	var enemy_spaces_in_the_same_column:Array = _get_enemy_spaces_from_same_column()
	var destinations_indexes:Array = _get_destination_indexes_for_enemy_balls(enemy_spaces_in_the_same_column)
	for i in destinations_indexes.size():
		var destination_index:int = destinations_indexes[i]
		if destination_index == -1:
			enemy_spaces_in_the_same_column.remove_at(i)
	destinations_indexes = destinations_indexes.filter(func(index:int) -> bool: return index != -1)
	var enemy_spaces_indexes := enemy_spaces_in_the_same_column.map(func(space:BingoSpaceData) -> int: return space.index)
	await Singletons.game_main._bingo_controller.handle_move_balls(enemy_spaces_indexes, destinations_indexes)
	_placed_on_board_event_finished.emit()

func _get_enemy_spaces_from_same_column() -> Array:
	var column := BingoBoard.find_column(bingo_space_data.index)
	var enemy_spaces:Array = bingo_board.board.filter(func(space:BingoSpaceData) -> bool:
		return space.ball_data && space.ball_data.team == BingoBallData.Team.ENEMY && BingoBoard.find_column(space.index) == column && space.index != bingo_space_data.index
	)
	return enemy_spaces

func _get_destination_indexes_for_enemy_balls(enemy_ball_spaces:Array) -> Array:
	var destination_spaces:Array = []
	for enemy_ball_space:BingoSpaceData in enemy_ball_spaces:
		var row := BingoBoard.find_row(enemy_ball_space.index)
		var occupied_columns := []
		for c in range(0, BingoBoard.SIZE):
			var index := BingoBoard.get_index(row, c)
			if bingo_board.board[index].ball_data:	
				occupied_columns.append(c)
		var available_columns := range(0, BingoBoard.SIZE).filter(func(c:int) -> bool: return !occupied_columns.has(c))
		if available_columns.size() == 0:
			destination_spaces.append(-1)
			continue
		var random_index_in_the_same_row = BingoBoard.get_index(row, available_columns.pick_random())
		destination_spaces.append(random_index_in_the_same_row)
	return destination_spaces
