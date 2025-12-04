class_name FieldStatusSeep
extends FieldStatus

func _has_tool_discard_hook(_count:int, plant:Plant) -> bool:
	return plant != null

func _handle_tool_discard_hook(plant:Plant, count:int) -> void:
	var action:ActionData = ActionData.new()
	var water_gain := (status_data.data["water"] as int) * stack * count
	action.type = ActionData.ActionType.WATER
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = water_gain
	await plant.apply_actions([action])
