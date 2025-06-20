class_name BingoBallScriptBloodSeeker
extends BingoBallScript

func _enhance_attack(_bingo_result:BingoResult, attack:Attack) -> void:
	attack.additional_damage = _count_bleed_balls() * (_bingo_ball_data.data["dmg"] as int)

func _has_power_up(_bingo_result:BingoResult) -> bool:
	return _count_bleed_balls() > 0

func _count_bleed_balls() -> int:
	var bleed_balls := bingo_board.board.filter(func(space:BingoSpaceData) -> bool:
		return space.ball_data && space.ball_data.base_id == "bleed"
	)
	return bleed_balls.size()
