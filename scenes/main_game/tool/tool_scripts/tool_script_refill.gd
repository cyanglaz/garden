class_name ToolScriptRefill
extends ToolScript

func apply_tool(combat_main:CombatMain, _tool_data:ToolData, _secondary_card_datas:Array) -> void:
	var all_empty_bottles:Array = combat_main.tool_manager.tool_deck.hand.filter(func(tool_data:ToolData) -> bool: return tool_data.id == "empty_bottle")
	var bottled_water_tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("bottled_water").get_duplicate()
	for empty_bottle_tool_data in all_empty_bottles:
		empty_bottle_tool_data.copy(bottled_water_tool_data)
		combat_main.tool_manager.update_tool_card(empty_bottle_tool_data, bottled_water_tool_data)
	await Util.await_for_tiny_time()

