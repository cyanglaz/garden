class_name BingoBallScriptMorningStar
extends BingoBallScript

func _enhance_attack(bingo_result:BingoResult, attack:Attack) -> void:
	if has_power_up(bingo_result):
		attack.additional_damage += _bingo_ball_data.data["dmg"] as int

func _has_power_up(_bingo_result:BingoResult) -> bool:
	if !bingo_space_data:
		return false
	return BingoBoard.find_column(bingo_space_data.index) == (_bingo_ball_data.data["col"] as int) - 1

func evaluate_for_description() -> void:
	if _has_power_up(null):
		_bingo_ball_data.highlight_description_keys["dmg"] = true
		_bingo_ball_data.highlight_description_keys["col"] = true
	else:
		_bingo_ball_data.highlight_description_keys["dmg"] = false
		_bingo_ball_data.highlight_description_keys["col"] = false
