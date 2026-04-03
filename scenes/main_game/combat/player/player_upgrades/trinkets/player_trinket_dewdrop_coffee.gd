class_name PlayerTrinketDewdropCoffee
extends PlayerTrinket

func _has_start_turn_hook(combat_main: CombatMain) -> bool:
	return combat_main.day_manager.day == int(data.data[&"turn"]) - 1

func _handle_start_turn_hook(_combat_main: CombatMain) -> void:
	_send_hook_animation_signals()
	Events.request_energy_update.emit(int(data.data[&"energy"]), ActionData.OperatorType.INCREASE)
