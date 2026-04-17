class_name ToolScriptRecharge
extends ToolScript

func apply_tool(combat_main:CombatMain, _tool_data:ToolData, secondary_card_datas:Array) -> void:
	await Util.await_for_tiny_time()
	for tool_data:ToolData in secondary_card_datas:
		var battery_tool_datas := []
		if tool_data.id == "solar_battery":
			battery_tool_datas.append(tool_data)
		if tool_data.back_card && tool_data.back_card.id == "solar_battery":
			battery_tool_datas.append(tool_data.back_card)
		if tool_data.front_card && tool_data.front_card.id == "solar_battery":
			battery_tool_datas.append(tool_data.front_card)
		assert(battery_tool_datas.size() > 0, "Recharge can only select solar battery")
		for battery_tool_data in battery_tool_datas:
			var light_action_data:ActionData  = battery_tool_data.actions[0]
			assert(light_action_data.type == ActionData.ActionType.LIGHT, "Solar battery's first action is light action")
			light_action_data.modified_x_value = 0
			battery_tool_data.refresh_ui(combat_main)

func number_of_secondary_cards_to_select() -> int:
	return 1

func secondary_card_selection_filter() -> Callable:
	return func(tool_data:ToolData) -> bool:
		var card_faces := [tool_data]
		if tool_data.back_card:
			card_faces.append(tool_data.back_card)
		if tool_data.front_card:
			card_faces.append(tool_data.front_card)
		for card_face in card_faces:
			if card_face.id == "solar_battery":
				return true
		return false

func get_card_selection_type() -> ActionData.CardSelectionType:
	return ActionData.CardSelectionType.RESTRICTED

func get_card_selection_custom_error_message() -> String:
	return Util.get_localized_string("WARNING_NO_CARD_IN_HAND") % "solar_battery"
