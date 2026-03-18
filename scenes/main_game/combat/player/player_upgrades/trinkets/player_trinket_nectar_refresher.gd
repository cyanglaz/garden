class_name PlayerTrinketNectarRefresher
extends PlayerTrinket

func _has_start_turn_hook(combat_main: CombatMain) -> bool:
	return combat_main.day_manager.day == 2

func _handle_start_turn_hook(combat_main: CombatMain) -> void:
	assert(combat_main.day_manager.day == 2, "Nectar Refresher should only trigger on turn 3")
	await Util.await_for_small_time()
	combat_main.player.player_status_container.update_player_upgrade(
		"momentum", int(data.data[&"momentum"]), ActionData.OperatorType.INCREASE)
