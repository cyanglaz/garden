class_name BingoBallScriptCrossbow
extends BingoBallScript

func _enhance_attack(bingo_result:BingoResult, attack:Attack) -> void:
	if has_power_up(bingo_result):
		attack.additional_damage += _bingo_ball_data.data["dmg"] as int

func _has_power_up(bingo_result:BingoResult) -> bool:
	if !bingo_result:
		return false
	return bingo_result.bingo_type == BingoResult.BingoType.DIAGONAL
