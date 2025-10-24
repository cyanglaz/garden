class_name FieldStatusScriptRecycle
extends FieldStatusScript

func _has_add_water_hook(plant:Plant) -> bool:
	return plant != null

func _handle_add_water_hook(plant:Plant) -> void:
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("graywater").get_duplicate()
	var from_position:Vector2 = Util.get_node_canvas_position(plant) - GUIToolCardButton.SIZE / 2
	var number_of_cards := status_data.stack
	var cards:Array[ToolData] = []
	for i in number_of_cards:
		cards.append(tool_data.get_duplicate())
	await Singletons.main_game.combat_main.add_temp_tools_to_hand(cards, from_position, true)
