class_name BingoBallScriptSlow
extends BingoBallScript

const INSIGHT_DATA := preload("res://data/status_effects/status_effect_insight.tres")

func _has_self_bingo_events(_bingo_result:BingoResult) -> bool:
	return true

func _has_self_bingo_event_trigger_animation() -> bool:
	return true

func _handle_self_bingo_events(_bingo_result:BingoResult) -> void:
	Singletons.game_main._player.status_effect_manager.add_status_effect(INSIGHT_DATA, _bingo_ball_data.data["stack"] as int)
	_self_bingo_event_finished.emit()
