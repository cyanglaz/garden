class_name BingoBallScriptGaze
extends BingoBallScript

func _has_placement_events() -> bool:
	return true

func _on_remove_ball_operation_finished(bingo_controller:BingoController) -> void:
	bingo_controller.remove_ball_operation_finished.disconnect(_on_remove_ball_operation_finished)
	_placed_on_board_event_finished.emit()

func _handle_placement_events() -> void:
	var index:int = bingo_space_data.index
	var row_index:int = BingoBoard.find_row(index)
	var spaces_with_data_on_the_same_row := bingo_board.board.filter(func(space_data:BingoSpaceData) -> bool:
		return space_data.ball_data != null && space_data.index != bingo_space_data.index && BingoBoard.find_row(space_data.index) == row_index
	)
	var removal_count := spaces_with_data_on_the_same_row.size()
	if removal_count == 0:
		_placed_on_board_event_finished.emit()
		return
	var indexes:Array = spaces_with_data_on_the_same_row.map(func(space_data:BingoSpaceData) -> int:
		return space_data.index
	)
	Singletons.game_main._bingo_controller.remove_ball_operation_finished.connect(_on_remove_ball_operation_finished.bind(Singletons.game_main._bingo_controller))
	Singletons.game_main._bingo_controller.handle_remove_balls_from_board(indexes)