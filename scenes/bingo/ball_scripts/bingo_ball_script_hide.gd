class_name BingoBallScriptHide
extends BingoBallScript

func _has_placement_events() -> bool:
	return true

func _has_draw_events(draws:int) -> bool:
	var draws_to_remove := _bingo_ball_data.data["draw"] as int
	assert(draws <= draws_to_remove)
	return draws == draws_to_remove
		
func _handle_draw_events() -> void:
	Singletons.game_main._bingo_controller.remove_ball_operation_finished.connect(_on_remove_ball_operation_finished.bind(Singletons.game_main._bingo_controller))
	Singletons.game_main._bingo_controller.handle_remove_balls_from_board([bingo_space_data.index])

func _handle_placement_events() -> void:
	for adjacent_space:BingoSpaceData in get_adjacent_spaces():
		adjacent_space.space_effect_manager.add_space_effect(MainDatabase.space_effect_database.get_data_by_id("disabled"), 1)
	_placed_on_board_event_finished.emit()

func _handle_removed_from_board() -> void:
	for adjacent_space:BingoSpaceData in get_adjacent_spaces():
		adjacent_space.space_effect_manager.reduce_space_effect("disabled", 1)

func get_adjacent_spaces() -> Array[BingoSpaceData]:
	var adjacent_spaces:Array[BingoSpaceData] = []
	var index:int = bingo_space_data.index
	var adjacent_space_ids:Array[int] = []
	if index % BingoBoard.SIZE != 0:
		adjacent_space_ids.append(index - 1)
	if index % BingoBoard.SIZE != BingoBoard.SIZE - 1:
		adjacent_space_ids.append(index + 1)
	@warning_ignore("integer_division")
	if index / BingoBoard.SIZE > 0:
		adjacent_space_ids.append(index - BingoBoard.SIZE)
	@warning_ignore("integer_division")
	if index / BingoBoard.SIZE < BingoBoard.SIZE - 1:
		adjacent_space_ids.append(index + BingoBoard.SIZE)
	for adjacent_space_id:int in adjacent_space_ids:
		if adjacent_space_id < bingo_board.board.size() && adjacent_space_id >= 0:
			adjacent_spaces.append(bingo_board.board[adjacent_space_id])
	return adjacent_spaces

func _on_remove_ball_operation_finished(bingo_controller:BingoController) -> void:
	bingo_controller.remove_ball_operation_finished.disconnect(_on_remove_ball_operation_finished)
	_draw_event_finished.emit()
