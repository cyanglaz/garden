class_name BingoBallScriptRend
extends BingoBallScript

func _enhance_attack(bingo_result:BingoResult, attack:Attack) -> void:
	if has_power_up(bingo_result):
		var bleed_count := _count_bleed_in_the_same_bingo(bingo_result)
		attack.additional_damage += (_bingo_ball_data.data["dmg"] as int) * bleed_count

func _has_power_up(bingo_result:BingoResult) -> bool:
	return _count_bleed_in_the_same_bingo(bingo_result) > 0

func _count_bleed_in_the_same_bingo(bingo_result:BingoResult) -> int:
	var ball_datas := bingo_result.spaces.map(func(space:BingoSpaceData) -> BingoBallData: return space.ball_data)
	return ball_datas.filter(func(ball_data:BingoBallData) -> bool: return ball_data.base_id == "bleed").size()
