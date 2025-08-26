class_name FieldStatusScriptDewCollector
extends FieldStatusScript

func _has_tool_discard_hook(_count:int, plant:Plant) -> bool:
	return plant != null

func _handle_tool_discard_hook(plant:Plant, count:int) -> void:
	var action:ActionData = ActionData.new()
	var stack := status_data.stack
	var water_gain := (status_data.data["water"] as int) * stack * count
	action.type = ActionData.ActionType.WATER
	action.value = water_gain
	await plant.field.apply_actions([action])
