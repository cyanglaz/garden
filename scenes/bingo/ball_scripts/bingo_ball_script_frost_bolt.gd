class_name BingoBallScriptFrostBolt
extends BingoBallScript

const SLOW_BALL_DATA := preload("res://data/balls/status/bingo_ball_slow.tres")

func _has_self_bingo_events(_bingo_result:BingoResult) -> bool:
	return true

func _has_async_self_bingo_events() -> bool:
	return true

func _handle_self_bingo_events(_bingo_result:BingoResult) -> void:
	var ball_data := SLOW_BALL_DATA
	Singletons.game_main._bingo_controller.summon_ball_operation_finished.connect(_on_summon_operation_finished)
	Singletons.game_main._bingo_controller.summon_balls_from_space([ball_data], bingo_space_data.index, -1)

func _on_summon_operation_finished() -> void:
	Singletons.game_main._bingo_controller.summon_ball_operation_finished.disconnect(_on_summon_operation_finished)
	_self_bingo_event_finished.emit()
