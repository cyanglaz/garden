class_name FieldStatusScriptGreenhouse
extends FieldStatusScript

func _has_tool_application_hook() -> bool:
	return true

func _handle_tool_application_hook(plant:Plant) -> void:
	var action:ActionData = ActionData.new()
	action.type = ActionData.ActionType.LIGHT
	action.value = 1
	await plant.field.apply_actions([action])
