class_name PlayerTrinketHummingbirdFeather
extends PlayerTrinket

func _has_tool_application_hook(_combat_main: CombatMain, _tool_data: ToolData) -> bool:
	return true

func _handle_tool_application_hook(combat_main: CombatMain, _tool_data: ToolData) -> void:
	var trinket_data := data as TrinketData
	trinket_data.stack += 1
	if trinket_data.stack >= int(data.data[&"threshold"]):
		combat_main.player.player_status_container.update_player_upgrade(
			"momentum", int(data.data[&"momentum"]), ActionData.OperatorType.INCREASE)
		trinket_data.stack = 0
