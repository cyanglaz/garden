class_name BingoBallScriptLightGlove
extends BingoBallScript

func _has_placement_events() -> bool:
	return true

func _handle_placement_events() -> void:
	var space_to_left := _bingo_ball_data.data["grid"] as int
	var index:int = bingo_space_data.index
	var column_index:int = BingoBoard.find_column(index)
	if column_index == 0:
		_placed_on_board_event_finished.emit()
		return
	var spaces_with_data_on_the_same_column := bingo_board.board.filter(func(space_data:BingoSpaceData) -> bool:
		var is_same_column := space_data.ball_data != null && space_data.index != bingo_space_data.index && BingoBoard.find_column(space_data.index) == column_index
		var left_space:BingoSpaceData = bingo_board.board[space_data.index - space_to_left]
		var left_space_is_empty := left_space.ball_data == null
		return is_same_column && left_space_is_empty
	)
	if spaces_with_data_on_the_same_column.is_empty():
		_placed_on_board_event_finished.emit()
		return
	var from_indexes:Array = spaces_with_data_on_the_same_column.map(func(space_data:BingoSpaceData) -> int:
		return space_data.index
	)
	var to_indexes:Array = from_indexes.map(func(i:int) -> int:
		return i - space_to_left
	)
	_update_moving_symbols(from_indexes)
	await Singletons.game_main._bingo_controller.handle_move_balls(from_indexes, to_indexes)
	_placed_on_board_event_finished.emit()

func _update_moving_symbols(indexes:Array) -> void:
	for index in indexes:
		var space:BingoSpaceData = bingo_board.board[index]
		assert(space.ball_data)
		if space.ball_data && space.ball_data.type == BingoBallData.Type.ATTACK:
			space.ball_data.combat_dmg_boost += _bingo_ball_data.data["dmg"] as int
			var first_time_moved := !space.ball_data.data.has("light_glove_move_damage")
			if first_time_moved:
				space.ball_data.data["light_glove_move_damage"] = _bingo_ball_data.data["dmg"] as int
				space.ball_data.description += "{light_glove_move_damage_text}"
			else:
				space.ball_data.data["light_glove_move_damage"] += _bingo_ball_data.data["dmg"] as int
			space.ball_data.data["light_glove_move_damage_text"] = Util.get_localized_string("LIGHT_GLOVE_MOVE_DAMAGE_STRING")%[space.ball_data.data["light_glove_move_damage"]]
			space.ball_data.highlight_description_keys["light_glove_move_damage_text"] = true
