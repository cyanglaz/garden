class_name PlayerTrinketSunCatcherPin
extends PlayerTrinket

func _has_tool_application_hook(_combat_main: CombatMain, _tool_data: ToolData) -> bool:
	return true

func _handle_tool_application_hook(combat_main: CombatMain, _tool_data: ToolData) -> void:
	var trinket_data := data as TrinketData
	trinket_data.stack += 1
	if trinket_data.stack == int(data.data[&"cards_played"]) - 1:
		data.state = TrinketData.TrinketState.ACTIVE
	if trinket_data.stack >= int(data.data[&"cards_played"]):
		trinket_data.stack = 0
		var plant := combat_main.get_current_player_plant()
		var light_action := ActionData.new()
		light_action.type = ActionData.ActionType.LIGHT
		light_action.operator_type = ActionData.OperatorType.INCREASE
		light_action.value = int(data.data[&"light"])
		_send_hook_animation_signals()
		await plant.apply_actions([light_action])
		data.state = TrinketData.TrinketState.NORMAL
