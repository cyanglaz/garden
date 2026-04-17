class_name ToolScriptRefill
extends ToolScript

func apply_tool(combat_main:CombatMain, _tool_data:ToolData, secondary_card_datas:Array) -> void:
	var selected_tool_data:ToolData = secondary_card_datas.front()
	var bottled_water_tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("bottled_water").get_duplicate()
	var new_tool_data:ToolData = selected_tool_data.get_duplicate()
	if new_tool_data.id == "empty_bottle":
		var back = new_tool_data.back_card
		var front = new_tool_data.front_card
		new_tool_data.copy(bottled_water_tool_data)
		new_tool_data.back_card = back
		new_tool_data.front_card = front
	if new_tool_data.back_card && new_tool_data.back_card.id == "empty_bottle":
		new_tool_data.back_card.copy(bottled_water_tool_data)
		new_tool_data.back_card.front_card = new_tool_data
	if new_tool_data.front_card && new_tool_data.front_card.id == "empty_bottle":
		new_tool_data.front_card.copy(bottled_water_tool_data)
		new_tool_data.front_card.back_card = new_tool_data
	combat_main.tool_manager.update_tool_card(selected_tool_data, new_tool_data)
	await Util.await_for_tiny_time()

func number_of_secondary_cards_to_select() -> int:
	return 1

func secondary_card_selection_filter() -> Callable:
	return func(tool_data:ToolData) -> bool:
		return [tool_data, tool_data.back_card, tool_data.front_card].any(
			func(f): return f != null && f.id == "empty_bottle"
		)

func get_card_selection_type() -> ActionData.CardSelectionType:
	return ActionData.CardSelectionType.RESTRICTED
