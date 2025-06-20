class_name BingoBallScriptTackle
extends BingoBallScript

func has_all_bingo_events(bingo_result:BingoResult) -> bool:
	return _is_correct_row(bingo_result)

func _is_correct_row(bingo_result:BingoResult) -> bool:
	if bingo_result.bingo_type != BingoResult.BingoType.ROW:
		return false
	var space_data := bingo_result.spaces[0]
	if BingoBoard.find_row(space_data.index) + 1 == (_bingo_ball_data.data["row"] as int):
		return true
	return false

func _handle_all_bingo_events() -> void:
	await Singletons.game_main._bingo_controller.handle_one_space_bingo(bingo_space_data, null)
	_all_bingo_event_finished.emit()
