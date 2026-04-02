class_name PlayerStatusMulch
extends PlayerStatus

func _has_discard_hook(_combat_main:CombatMain, _tool_datas:Array) -> bool:
	return true

func _handle_discard_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	var player_action_applier:PlayerActionApplier = PlayerActionApplier.new()
	var action:ActionData = ActionData.new()
	action.type = ActionData.ActionType.DRAW_CARD
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = (data.data["value"] as int) * stack * tool_datas.size()
	await player_action_applier.apply_action(action, combat_main, [])
