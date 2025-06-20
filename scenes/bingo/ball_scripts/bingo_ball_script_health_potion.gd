class_name BingoBallScriptHealthPotion
extends BingoBallScript

func _has_self_bingo_events(_bingo_result:BingoResult) -> bool:
	return true

func _has_self_bingo_event_trigger_animation() -> bool:
	return true

func _handle_self_bingo_events(_bingo_result:BingoResult) -> void:
	Singletons.game_main._player.animate_restore_hp(_bingo_ball_data.data["hp"] as int)
	_self_bingo_event_finished.emit()
