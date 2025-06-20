class_name BingoBallScriptBleed
extends BingoBallScript

func _has_self_bingo_events(_bingo_result:BingoResult) -> bool:
	return true

func _has_self_bingo_event_trigger_animation() -> bool:
	return true

func _handle_self_bingo_events(_bingo_result:BingoResult) -> void:
	var attack:Attack = Attack.new(_bingo_ball_data.owner, _bingo_ball_data.data["dmg"] as int)
	await Singletons.game_main._player.animate_receive_attack(attack)
	_self_bingo_event_finished.emit()
