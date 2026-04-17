class_name ToolScriptRefill
extends ToolScript

func apply_tool(combat_main:CombatMain, _tool_data:ToolData, secondary_card_datas:Array) -> void:
	var selected_tool_data:ToolData = secondary_card_datas.front()
	var bottled_water_tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("bottled_water").get_duplicate()
	var new_tool_data:ToolData = selected_tool_data.get_duplicate()
	if selected_tool_data.id == "empty_bottle":
		new_tool_data = bottled_water_tool_data.get_duplicate()
	if selected_tool_data.back_card && selected_tool_data.back_card.id == "empty_bottle":
		new_tool_data.back_card = bottled_water_tool_data.get_duplicate()
	if selected_tool_data.front_card && selected_tool_data.front_card.id == "empty_bottle":
		new_tool_data.front_card = bottled_water_tool_data.get_duplicate()
	combat_main.tool_manager.update_tool_card(selected_tool_data, new_tool_data)
	await Util.await_for_tiny_time()

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
			if card_face.id == "empty_bottle":
				return true
		return false

func get_card_selection_type() -> ActionData.CardSelectionType:
	return ActionData.CardSelectionType.RESTRICTED
