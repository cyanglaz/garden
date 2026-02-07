class_name PlayerStatusRegenerator
extends PlayerStatus

func _has_status_stack_update_hook(_combat_main:CombatMain, status_id:String, diff:int) -> bool:
	return diff < 0 && status_id == "momentum"

func _handle_status_stack_update_hook(combat_main:CombatMain, status_id:String, _diff:int) -> void:
	assert(status_id == "momentum")
	var action:ActionData = ActionData.new()
	action.type = ActionData.ActionType.LIGHT
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = stack * (status_data.data["value"] as int)
	var player_plant:Plant = combat_main.get_current_player_plant()
	await player_plant.apply_actions([action])
