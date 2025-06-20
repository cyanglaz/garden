class_name BingoBallScriptDagger
extends BingoBallScript

func _enhance_attack(bingo_result:BingoResult, attack:Attack) -> void:
	if has_power_up(bingo_result):
		attack.additional_damage += _bingo_ball_data.data["dmg"] as int

func _has_power_up(_bingo_result:BingoResult) -> bool:
	if !bingo_space_data:
		return false
	return BingoBoard.is_corner(bingo_space_data.index)

func evaluate_for_description() -> void:
	if _has_power_up(null):
		_bingo_ball_data.highlight_description_keys["dmg"] = true
		_bingo_ball_data.highlight_description_keys["corner"] = true
	else:
		_bingo_ball_data.highlight_description_keys["dmg"] = false
		_bingo_ball_data.highlight_description_keys["corner"] = false
