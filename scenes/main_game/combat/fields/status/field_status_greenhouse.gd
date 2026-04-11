class_name FieldStatusGreenhouse
extends FieldStatus

func _has_tool_application_hook(plant:Plant) -> bool:
	return plant != null

func _handle_tool_application_hook(plant:Plant, combat_main:CombatMain) -> void:
	var action:ActionData = ActionData.new()
	var light_gain := (status_data.data["light"] as int) * stack
	action.type = ActionData.ActionType.LIGHT
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = light_gain
	assert(false, "TODO: Implement field status greenhouse tool application hook with combat main")
	await plant.apply_actions([action], combat_main)
