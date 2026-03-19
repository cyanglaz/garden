class_name PlayerTrinketGlassMarble
extends PlayerTrinket

func _has_start_turn_hook(combat_main: CombatMain) -> bool:
	return combat_main.day_manager.day == 0

func _handle_start_turn_hook(combat_main: CombatMain) -> void:
	assert(combat_main.day_manager.day == 0, "Glass Marble should only trigger on turn 1")
	var current_plant: Plant = combat_main.plant_field_container.get_plant(combat_main.player.current_field_index)
	var action_data := ActionData.new()
	action_data.type = ActionData.ActionType.LIGHT
	action_data.operator_type = ActionData.OperatorType.INCREASE
	action_data.value = int(data.data[&"light"])
	await current_plant.apply_actions([action_data])
