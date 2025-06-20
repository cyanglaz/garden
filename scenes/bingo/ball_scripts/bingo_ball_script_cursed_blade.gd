class_name BingoBallScriptCursedBlade
extends BingoBallScript

const BLEED_BALL_DATA := preload("res://data/balls/status/bingo_ball_bleed.tres")

func _has_draw_events(draws:int) -> bool:
	return draws % (_bingo_ball_data.data["draw"] as int) == 0

func _handle_draw_events() -> void:
	Singletons.game_main._bingo_controller.summon_ball_operation_finished.connect(_on_summon_operation_finished)
	Singletons.game_main._bingo_controller.summon_balls_from_space([BLEED_BALL_DATA], bingo_space_data.index, -1)

func _on_summon_operation_finished() -> void:
	Singletons.game_main._bingo_controller.summon_ball_operation_finished.disconnect(_on_summon_operation_finished)
	_draw_event_finished.emit()
