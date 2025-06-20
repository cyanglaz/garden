class_name BingoBallScriptHammer
extends BingoBallScript

func _has_self_bingo_events(_bingo_result:BingoResult) -> bool:
	return true

func _handle_self_bingo_events(_bingo_result:BingoResult) -> void:
	Singletons.game_main.enemy_controller.get_current_enemy().animate_decrease_attack_counters(_bingo_ball_data.data["energy"] as int)
