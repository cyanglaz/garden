class_name PlayerTrinketSporeGlass
extends PlayerTrinket

func _has_hand_size_hook(combat_main: CombatMain) -> bool:
	for plant: Plant in combat_main.plant_field_container.plants:
		var fungus_count := plant.field_status_container.get_status_stack("fungus")
		if fungus_count > 0:
			return true
	return false

func _handle_hand_size_hook(_combat_main: CombatMain) -> int:
	_send_hook_animation_signals()
	return int(data.data[&"draw"])
