class_name PlayerTrinketFieldLog
extends PlayerTrinket

var _triggered := false

func _has_player_move_hook(combat_main: CombatMain) -> bool:
	if _triggered:
		return false
	return combat_main.player.current_field_index == combat_main.player.max_plants_index

func _handle_player_move_hook(_combat_main: CombatMain) -> void:
	assert(!_triggered)
	_triggered = true
	_send_hook_animation_signals()
	Events.request_energy_update.emit(int(data.data[&"energy"]), ActionData.OperatorType.INCREASE)
