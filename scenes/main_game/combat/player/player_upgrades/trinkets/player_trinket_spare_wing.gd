class_name PlayerTrinketSpareWing
extends PlayerTrinket

func _has_start_turn_hook(combat_main:CombatMain) -> bool:
	var momentum:int = combat_main.player.player_status_container.get_player_upgrade_stack("momentum")
	return momentum == 0

func _handle_start_turn_hook(combat_main:CombatMain) -> void:
	var momentum:int = combat_main.player.player_status_container.get_player_upgrade_stack("momentum")
	assert(momentum == 0, "Momentum is not 0")
	_send_hook_animation_signals()
	combat_main.player.player_status_container.set_player_upgrade("momentum", 1)
