class_name PlayerTrinketRainbowEgg
extends PlayerTrinket

func _has_start_turn_hook(combat_main: CombatMain) -> bool:
	return combat_main.day_manager.day == int(data.data[&"turn"]) - 1

func _handle_start_turn_hook(combat_main: CombatMain) -> void:
	assert(combat_main.day_manager.day == int(data.data[&"turn"]) - 1, "Rainbow Egg should only trigger on turn %s" % data.data[&"turn"])
	for plant: Plant in combat_main.plant_field_container.plants:
		var action_water := ActionData.new()
		action_water.type = ActionData.ActionType.WATER
		action_water.operator_type = ActionData.OperatorType.INCREASE
		action_water.value = int(data.data[&"water"])
		var action_light := ActionData.new()
		action_light.type = ActionData.ActionType.LIGHT
		action_light.operator_type = ActionData.OperatorType.INCREASE
		action_light.value = int(data.data[&"light"])
		await plant.apply_actions([action_water, action_light])
