class_name BingoBallScriptLeechBolt
extends BingoBallScript

func _has_self_bingo_events(_bingo_result:BingoResult) -> bool:
	return true

func _handle_self_bingo_events(_bingo_result:BingoResult) -> void:
	_bingo_ball_data.owner.animate_restore_hp(_bingo_ball_data.data["hp"] as int, 0.2)
