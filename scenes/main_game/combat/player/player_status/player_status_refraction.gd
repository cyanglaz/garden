class_name PlayerRefraction
extends PlayerStatus

func _has_target_plant_water_update_hook(_combat_main:CombatMain, _plant:Plant, diff:int) -> bool:
	return diff > 0

func _handle_target_plant_water_update_hook(_combat_main:CombatMain, plant:Plant, diff:int) -> void:
	assert(diff > 0)
	var action:ActionData = ActionData.new()
	action.type = ActionData.ActionType.LIGHT
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = stack * (status_data.data["value"] as int)
	await plant.apply_actions([action])
