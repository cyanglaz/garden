class_name BingoBallScriptChillWave
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
	for adjacent_space:BingoSpaceData in _get_column_spaces():
		adjacent_space.space_effect_manager.add_space_effect(MainDatabase.space_effect_database.get_data_by_id("disabled"), 1)
	_placed_on_board_event_finished.emit()

func _handle_removed_from_board() -> void:
	for adjacent_space:BingoSpaceData in _get_column_spaces():
		adjacent_space.space_effect_manager.reduce_space_effect("disabled", 1)

func _get_column_spaces() -> Array:
	var index:int = bingo_space_data.index
	var column = BingoBoard.find_column(index)
	var column_spaces:Array = bingo_board.board.filter(func(space:BingoSpaceData): return BingoBoard.find_column(space.index) == column && space.index != index)
	return column_spaces

func _on_remove_ball_operation_finished(bingo_controller:BingoController) -> void:
	bingo_controller.remove_ball_operation_finished.disconnect(_on_remove_ball_operation_finished)
	_draw_event_finished.emit()
