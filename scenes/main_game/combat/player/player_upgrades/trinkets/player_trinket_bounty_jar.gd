class_name PlayerTrinketBountyJar
extends PlayerTrinket

func _has_pre_tool_application_hook(combat_main: CombatMain, tool_data: ToolData) -> bool:
	var plant:Plant = combat_main.plant_field_container.get_plant(combat_main.player.current_field_index)
	if plant == null:
		return false
	return _will_decrease_pest_on_application(tool_data, plant)

func _handle_pre_tool_application_hook(combat_main: CombatMain, tool_data: ToolData) -> void:
	Events.request_update_gold.emit(int(data.data[&"gold"]), true)

func _will_decrease_pest_on_application(tool_data: ToolData, plant: Plant) -> bool:
	var pest_count := plant.field_status_container.get_status_stack("pest")
	if pest_count == 0:
		return false
	for action: ActionData in tool_data.actions:
		if action.type == ActionData.ActionType.PEST and action.operator_type == ActionData.OperatorType.DECREASE:
			return true
		if action.type == ActionData.ActionType.PEST and action.operator_type == ActionData.OperatorType.EQUAL_TO:
			return action.value < pest_count
	return false

