class_name PlayerTrinketEscapeWing
extends PlayerTrinket

var _triggered := false

func _has_damage_taken_hook(_combat_main: CombatMain, _damage: int) -> bool:
	return not _triggered

func _handle_damage_taken_hook(combat_main: CombatMain, _damage: int) -> void:
	_triggered = true
	combat_main.player.player_status_container.update_player_upgrade(
		"momentum", 2, ActionData.OperatorType.INCREASE)
