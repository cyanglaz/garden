class_name FieldStatusScriptFungus
extends FieldStatusScript

func _has_end_turn_hook(plant:Plant) -> bool:
	return plant != null

func _handle_end_turn_hook(_combat_main:CombatMain, plant:Plant) -> void:
	var reduce_water_action:ActionData = ActionData.new()
	reduce_water_action.type = ActionData.ActionType.WATER
	reduce_water_action.operator_type = ActionData.OperatorType.DECREASE
	reduce_water_action.value = (status_data.data["value"] as int) * status_data.stack
	await plant.apply_actions([reduce_water_action])
