class_name PlayerTrinketBountyJar
extends PlayerTrinket

func _has_pre_tool_application_hook(combat_main: CombatMain, tool_data: ToolData) -> bool:
	if not _has_pest_decrease_action(tool_data):
		return false
	var plant := combat_main.plant_field_container.get_plant(combat_main.player.current_field_index)
	if plant == null:
		return false
	return _plant_has_pest(plant)

func _handle_pre_tool_application_hook(_combat_main: CombatMain, _tool_data: ToolData) -> void:
	Events.request_update_gold.emit(int(data.data[&"gold"]), true)
	await Util.await_for_tiny_time()

func _has_pest_decrease_action(tool_data: ToolData) -> bool:
	if tool_data == null:
		return false
	for action: ActionData in tool_data.actions:
		if action.type == ActionData.ActionType.PEST and action.operator_type == ActionData.OperatorType.DECREASE:
			return true
	return false

func _plant_has_pest(plant: Plant) -> bool:
	for status in plant.field_status_container.get_all_statuses():
		if status.status_data.id == "pest":
			return true
	return false
