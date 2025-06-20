class_name BingoBallScriptCrossblade
extends BingoBallScript

func _enhance_attack(bingo_result:BingoResult, attack:Attack) -> void:
	if has_power_up(bingo_result):
		var counter_count:int = 0
		for space:BingoSpaceData in bingo_result.spaces:
			if BingoBoard.is_corner(space.index) && space.index != bingo_space_data.index:
				counter_count += 1
		attack.additional_damage += (_bingo_ball_data.data["dmg"] as int) * counter_count

func _has_power_up(bingo_result:BingoResult) -> bool:
	if !bingo_result:
		return false
	var has_connected_corners := false
	for space:BingoSpaceData in bingo_result.spaces:
		if BingoBoard.is_corner(space.index) && space.index != bingo_space_data.index:
			has_connected_corners = true
			break
	return has_connected_corners
