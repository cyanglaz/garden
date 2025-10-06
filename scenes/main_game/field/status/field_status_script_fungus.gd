class_name FieldStatusScriptFungus
extends FieldStatusScript

func _has_end_day_hook(plant:Plant) -> bool:
	return plant != null

func _handle_end_day_hook(_main_game:MainGame, plant:Plant) -> void:
	var reduce_water_action:ActionData = ActionData.new()
	reduce_water_action.type = ActionData.ActionType.WATER
	reduce_water_action.value = - (status_data.data["value"] as int) * status_data.stack
	await plant.field.apply_action(reduce_water_action)
