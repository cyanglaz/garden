class_name PlayerStatusCondensation
extends PlayerStatus

func _has_discard_hook(_combat_main:CombatMain, _tool_data:ToolData) -> bool:
	return true

func _handle_discard_hook(combat_main:CombatMain, _tool_data:ToolData) -> void:
	var action:ActionData = ActionData.new()
	var water_gain := (status_data.data["value"] as int) * stack
	action.type = ActionData.ActionType.WATER
	action.operator_type = ActionData.OperatorType.INCREASE
	action.value = water_gain
	var player_plant:Plant = combat_main.get_current_player_plant()
	await player_plant.apply_actions([action])

