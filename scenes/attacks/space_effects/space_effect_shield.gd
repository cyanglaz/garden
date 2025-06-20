class_name SpaceEffectShield
extends SpaceEffect
		
func _has_bingo_event(bingo_space_data:BingoSpaceData) -> bool:
	return bingo_space_data.ball_data.team == BingoBallData.Team.ENEMY && bingo_space_data.ball_data.type == BingoBallData.Type.ATTACK

func _on_trigger_animation_finished(bingo_space_data:BingoSpaceData, event_trigger_type:EventTriggerType) -> void:
	super._on_trigger_animation_finished(bingo_space_data, event_trigger_type)
	assert(event_trigger_type == EventTriggerType.BINGO)
	bingo_space_data.ball_data.combat_dmg_boost -= (data.data["dmg"] as int) * stack
	_bingo_event_finished.emit()