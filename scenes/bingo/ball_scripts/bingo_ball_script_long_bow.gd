class_name BingoBallScriptLongBow
extends BingoBallScript

func _enhance_attack(_bingo_result:BingoResult, attack:Attack) -> void:
	var spaces_to_right := _find_spaces_to_right()
	attack.additional_damage += spaces_to_right * (_bingo_ball_data.data["dmg"] as int)

func evaluate_for_description() -> void:
	var spaces_to_right := _find_spaces_to_right()
	if spaces_to_right > 0:
		_bingo_ball_data.data["spaces"] = "(" + str(spaces_to_right) + ")"
		_bingo_ball_data.highlight_description_keys["spaces"] = true
	else:
		_bingo_ball_data.highlight_description_keys["spaces"] = false

func _find_spaces_to_right() -> int:
	if !bingo_space_data:
		return 0
	var row_index := BingoBoard.find_row(bingo_space_data.index)
	var empty_spaces_same_row := bingo_board.board.filter(func(space:BingoSpaceData) -> bool: return BingoBoard.find_row(space.index) == row_index && space.ball_data == null && space.index > bingo_space_data.index)
	return empty_spaces_same_row.size()
