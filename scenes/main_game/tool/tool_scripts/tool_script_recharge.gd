class_name ToolScriptRecharge
extends ToolScript

func apply_tool(combat_main:CombatMain, _tool_data:ToolData, _secondary_card_datas:Array) -> void:
	var all_solar_batteries:Array = combat_main.tool_manager.tool_deck.hand.filter(func(tool_data:ToolData) -> bool: return tool_data.id == "solar_battery")
	for solar_battery_tool_data in all_solar_batteries:
		var light_action_data:ActionData  = solar_battery_tool_data.actions[0]
		assert(light_action_data.type == ActionData.ActionType.LIGHT, "Solar battery's first action is light action")
		light_action_data.modified_x_value = 0
		solar_battery_tool_data.refresh_ui(combat_main)
