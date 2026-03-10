class_name PlayerStatusOverclock
extends PlayerStatus

func _has_draw_hook(_combat_main:CombatMain, _tool_datas:Array) -> bool:
	return true

func _handle_draw_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	var player_action_applier:PlayerActionApplier = PlayerActionApplier.new()
	var action:ActionData = ActionData.new()
	action.type = ActionData.ActionType.MOMENTUM
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = stack * tool_datas.size()
	await player_action_applier.apply_action(action, combat_main, [])
