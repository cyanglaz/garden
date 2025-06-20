class_name BingoBallScriptShieldWall
extends BingoBallScript

func _has_placement_events() -> bool:
	return true

func _handle_placement_events() -> void:
	for adjacent_space:BingoSpaceData in _get_spaces_on_the_same_column():
		adjacent_space.space_effect_manager.add_space_effect(MainDatabase.space_effect_database.get_data_by_id("shield"), _bingo_ball_data.data["stack"] as int)
	_placed_on_board_event_finished.emit()

func _get_spaces_on_the_same_column() -> Array:
	var column_index:int = BingoBoard.find_column(bingo_space_data.index)
	var spaces := bingo_board.board.filter(func(space_data:BingoSpaceData) -> bool:
		var is_same_column := space_data.index != bingo_space_data.index && BingoBoard.find_column(space_data.index) == column_index
		return is_same_column
	)
	return spaces

func _handle_removed_from_board() -> void:
	for adjacent_space:BingoSpaceData in _get_spaces_on_the_same_column():
		adjacent_space.space_effect_manager.reduce_space_effect("shield", _bingo_ball_data.data["stack"] as int)