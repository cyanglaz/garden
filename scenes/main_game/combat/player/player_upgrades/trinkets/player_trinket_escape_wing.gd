class_name PlayerTrinketEscapeWing
extends PlayerTrinket

var _triggered := false

func _has_start_turn_hook(combat_main: CombatMain) -> bool:
	return combat_main.day_manager.day == 0

func _handle_start_turn_hook(_combat_main: CombatMain) -> void:
	data.state = TrinketData.TrinketState.ACTIVE

func _has_damage_taken_hook(_combat_main: CombatMain, _damage: int) -> bool:
	return not _triggered

func _handle_damage_taken_hook(combat_main: CombatMain, _damage: int) -> void:
	_triggered = true
	_send_hook_animation_signals()
	combat_main.player.player_status_container.update_player_upgrade(
		"momentum", 2, ActionData.OperatorType.INCREASE)
	data.state = TrinketData.TrinketState.NORMAL

func _has_combat_end_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_combat_end_hook(_combat_main: CombatMain) -> void:
	data.state = TrinketData.TrinketState.NORMAL
