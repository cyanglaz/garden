class_name PlayerTrinketNectarRefresher
extends PlayerTrinket

func _has_start_turn_hook(combat_main: CombatMain) -> bool:
	return combat_main.day_manager.day == 2

func _handle_start_turn_hook(combat_main: CombatMain) -> void:
	assert(combat_main.day_manager.day == 2, "Nectar Refresher should only trigger on turn 3")
	_send_hook_animation_signals()
	combat_main.player.player_status_container.update_player_upgrade(
		"free_move", int(data.data[&"free_move"]), ActionData.OperatorType.INCREASE)
