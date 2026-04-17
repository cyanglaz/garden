class_name ToolScriptRefill
extends ToolScript

func apply_tool(combat_main:CombatMain, _tool_data:ToolData, secondary_card_datas:Array) -> void:
	var selected_tool_data:ToolData = secondary_card_datas.front()
	var bottled_water_tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("bottled_water").get_duplicate()

	# First pass, only worry about copying the card data, face will get copied later
	# new_tool_data is always the front face
	var front_face:ToolData
	var back_face:ToolData = null
	if selected_tool_data.front_card:
		front_face = selected_tool_data.front_card
		back_face = selected_tool_data
	else:
		front_face = selected_tool_data
		back_face = selected_tool_data.back_card

	# Transform to empty bottle for eligible faces
	if front_face.id == "empty_bottle":
		front_face.copy(bottled_water_tool_data)
	if back_face && back_face.id == "empty_bottle":
		back_face.copy(bottled_water_tool_data)
	
	front_face.back_card = back_face
	if back_face:
		back_face.front_card = front_face

	var update_from = selected_tool_data.front_card if selected_tool_data.front_card else selected_tool_data
	combat_main.tool_manager.update_tool_card(update_from, front_face)
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
