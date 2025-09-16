class_name ToolScriptCollect
extends ToolScript

func apply_tool(_main_game:MainGame, fields:Array, field_index:int, _tool_data:ToolData) -> void:
	var action_data:ActionData = ActionData.new()
	var field:Field = fields[field_index]
	action_data.type = ActionData.ActionType.WATER
	var water_to_reduce := field.plant.water.value
	action_data.value = -water_to_reduce
	await field.apply_actions([action_data])

	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("graywater").get_duplicate()
	var from_position:Vector2 = Util.get_node_ui_position(Singletons.main_game.gui_main_game.gui_tool_card_container, field.plant) - GUIToolCardButton.SIZE / 2
	var number_of_cards := water_to_reduce
	var cards:Array[ToolData] = []
	for i in number_of_cards:
		cards.append(tool_data.get_duplicate())
	await Singletons.main_game.add_temp_tools_to_hand(cards, from_position, true)
