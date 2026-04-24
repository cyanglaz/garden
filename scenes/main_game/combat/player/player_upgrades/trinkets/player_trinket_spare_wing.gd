class_name PlayerTrinketSpareWing
extends PlayerTrinket

func _has_start_turn_hook(combat_main:CombatMain) -> bool:
	var free_move:int = combat_main.player.player_status_container.get_player_upgrade_stack("free_move")
	return free_move == 0

func _handle_start_turn_hook(combat_main:CombatMain) -> void:
	var free_move:int = combat_main.player.player_status_container.get_player_upgrade_stack("free_move")
	assert(free_move == 0, "free_move is not 0")
	_send_hook_animation_signals()
	combat_main.player.player_status_container.set_player_upgrade("free_move", 1)
