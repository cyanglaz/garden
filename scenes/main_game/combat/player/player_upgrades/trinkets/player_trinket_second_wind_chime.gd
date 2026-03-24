class_name PlayerTrinketSecondWindChime
extends PlayerTrinket

func _has_tool_application_hook(_combat_main: CombatMain, _tool_data: ToolData) -> bool:
	return true

func _handle_tool_application_hook(_combat_main: CombatMain, _tool_data: ToolData) -> void:
	var trinket_data := data as TrinketData
	trinket_data.stack += 1
	if trinket_data.stack >= int(data.data[&"threshold"]):
		Events.request_energy_update.emit(int(data.data[&"energy"]), ActionData.OperatorType.INCREASE)
		trinket_data.stack = 0
