class_name PlayerStatusRegenerator
extends PlayerStatus

func _has_stack_update_hook(_combat_main:CombatMain, status_id:String, diff:int) -> bool:
	return diff < 0 && status_id == "free_move"

func _handle_stack_update_hook(combat_main:CombatMain, status_id:String, _diff:int) -> void:
	assert(status_id == "free_move")
	var action:ActionData = ActionData.new()
	action.type = ActionData.ActionType.LIGHT
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = stack * (data.data["value"] as int)
	var player_plant:Plant = combat_main.get_current_player_plant()
	_send_hook_animation_signals()
	await player_plant.apply_actions([action], combat_main)
