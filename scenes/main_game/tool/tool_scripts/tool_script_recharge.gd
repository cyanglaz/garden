class_name ToolScriptRecharge
extends ToolScript

func apply_tool(_main_game:MainGame, _fields:Array, _field_index:int, _tool_data:ToolData, secondary_card_datas:Array) -> void:
	await Util.await_for_tiny_time()
	for tool_data:ToolData in secondary_card_datas:
		assert(tool_data.id == "solar_battery", "Recharge can only select solar battery")
		var light_action_data:ActionData  = tool_data.actions[0]
		assert(light_action_data.type == ActionData.ActionType.LIGHT, "Solar battery's first action is light action")
		light_action_data.modified_x_value = 0

func need_select_field() -> bool:
	return false

func number_of_secondary_cards_to_select() -> int:
	return 1

func secondary_card_selection_filter() -> Callable:
	return func(tool_data:ToolData) -> bool:
		return tool_data.id in ["solar_battery"]
