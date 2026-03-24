class_name PlayerTrinketSporeGlass
extends PlayerTrinket

func _has_hand_size_hook(combat_main: CombatMain) -> bool:
	for plant: Plant in combat_main.plant_field_container.plants:
		for status in plant.field_status_container.get_all_statuses():
			if status.status_data.id == "fungus":
				return true
	return false

func _handle_hand_size_hook(_combat_main: CombatMain) -> int:
	return int(data.data[&"draw"])
