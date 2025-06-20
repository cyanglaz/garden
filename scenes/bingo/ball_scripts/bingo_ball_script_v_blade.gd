class_name BingoBallScriptVBlade
extends BingoBallScript

var _number_increased := 0

func _handle_player_lost_hp(damage:Damage) -> void:
	if damage.damage_received > 0:
		_number_increased += 1
		_bingo_ball_data.combat_dmg_boost = _number_increased * (_bingo_ball_data.data["dmg"] as int)

func evaluate_for_description() -> void:
	var total_dmg_increased := _number_increased * (_bingo_ball_data.data["dmg"] as int)
	_bingo_ball_data.data["total"] = "(+" + str(total_dmg_increased) + ")"
	if _number_increased > 0:
		_bingo_ball_data.highlight_description_keys["total"] = true
	else:
		_bingo_ball_data.highlight_description_keys["total"] = false
