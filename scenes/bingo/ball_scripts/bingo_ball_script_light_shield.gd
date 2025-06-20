class_name BingoBallScriptLightShield
extends BingoBallScript

func _has_self_bingo_events(bingo_result:BingoResult) -> bool:
	var next_enemy_attack:BingoBallData = _find_next_enemy_attack(bingo_result)
	if next_enemy_attack:
		return true
	return false

func _has_self_bingo_event_trigger_animation() -> bool:
	return true

func _handle_self_bingo_events(bingo_result:BingoResult) -> void:
	var next_enemy_attack:BingoBallData = _find_next_enemy_attack(bingo_result)
	if next_enemy_attack:
		next_enemy_attack.damage -= (_bingo_ball_data.data["dmg"] as int)
	_self_bingo_event_finished.emit()

func _find_next_enemy_attack(bingo_result:BingoResult) -> BingoBallData:
	var start_searching := false
	for space:BingoSpaceData in bingo_result.spaces:
		if space.index == bingo_space_data.index:
			start_searching = true
		if start_searching && space.ball_data.team == BingoBallData.Team.ENEMY && space.ball_data.type == BingoBallData.Type.ATTACK:
			return space.ball_data
	return null
