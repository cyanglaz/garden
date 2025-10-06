class_name FieldStatusScriptGreenhouse
extends FieldStatusScript

func _has_tool_application_hook(plant:Plant) -> bool:
	return plant != null

func _handle_tool_application_hook(plant:Plant) -> void:
	var action:ActionData = ActionData.new()
	var stack := status_data.stack
	var light_gain := (status_data.data["light"] as int) * stack
	action.type = ActionData.ActionType.LIGHT
	action.value = light_gain
	await plant.field.apply_action(action, null)
