class_name BingoBallScriptWarBow
extends BingoBallScript

func _enhance_attack(_bingo_result:BingoResult, attack:Attack) -> void:
	var space_count:int = _calculate_space_count()
	attack.additional_damage += space_count * (_bingo_ball_data.data["dmg"] as int)

func _calculate_space_count() -> int:
	if !bingo_space_data:
		return 0
	var space_count:int = 0
	var check_index := bingo_space_data.index - bingo_board.size
	while check_index >= 0:
		if bingo_board.board[check_index].ball_data == null:
			space_count += 1
		else:
			break
		check_index -= bingo_board.size
	return space_count

func evaluate_for_description() -> void:
	var count:int = _calculate_space_count()
	if count > 0:
		_bingo_ball_data.data["spaces"] = "(" + str(count) + ")"
		_bingo_ball_data.highlight_description_keys["spaces"] = true
	else:
		_bingo_ball_data.data["spaces"] = "(" + str(count) + ")"
		_bingo_ball_data.highlight_description_keys["spaces"] = false
