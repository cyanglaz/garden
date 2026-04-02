class_name PlayerTrinketLeakyCanteen
extends PlayerTrinket

func _has_tool_application_hook(_combat_main: CombatMain, _tool_data: ToolData) -> bool:
	return true

func _handle_tool_application_hook(combat_main: CombatMain, _tool_data: ToolData) -> void:
	var trinket_data := data as TrinketData
	trinket_data.stack += 1
	if trinket_data.stack >= int(data.data[&"cards_played"]):
		trinket_data.stack = 0
		var plant := combat_main.get_current_player_plant()
		var water_action := ActionData.new()
		water_action.type = ActionData.ActionType.WATER
		water_action.operator_type = ActionData.OperatorType.INCREASE
		water_action.value = int(data.data[&"water"])
		await plant.apply_actions([water_action])
