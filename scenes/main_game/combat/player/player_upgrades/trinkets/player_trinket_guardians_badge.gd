class_name PlayerTrinketGuardiansBadge
extends PlayerTrinket

func _has_end_turn_hook(combat_main: CombatMain) -> bool:
	for plant: Plant in combat_main.plant_field_container.plants:
		if plant.field_status_container.get_status_stack("pest") > 0:
			return false
		if plant.field_status_container.get_status_stack("fungus") > 0:
			return false
	return true

func _handle_end_turn_hook(combat_main: CombatMain) -> void:
	var plant: Plant = combat_main.get_current_player_plant()
	var light_action := ActionData.new()
	light_action.type = ActionData.ActionType.LIGHT
	light_action.operator_type = ActionData.OperatorType.INCREASE
	light_action.value = int(data.data[&"light"])
	var water_action := ActionData.new()
	water_action.type = ActionData.ActionType.WATER
	water_action.operator_type = ActionData.OperatorType.INCREASE
	water_action.value = int(data.data[&"water"])
	_send_hook_animation_signals()
	await plant.apply_actions([light_action, water_action])
