class_name ToolScriptCollect
extends ToolScript

func apply_tool(_combat_main:CombatMain, plants:Array, field_index:int, _tool_data:ToolData, _secondary_card_datas:Array) -> void:
	var action_data:ActionData = ActionData.new()
	var plant:Plant = plants[field_index]
	action_data.type = ActionData.ActionType.WATER
	var water_to_reduce := plant.water.value
	action_data.value = -water_to_reduce
	await plant.apply_actions([action_data], null)

	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("graywater").get_duplicate()
	var from_position:Vector2 = Util.get_node_canvas_position(plant) - GUIToolCardButton.SIZE / 2
	var number_of_cards := water_to_reduce * (_tool_data.data["gain"] as int)
	var cards:Array[ToolData] = []
	for i in number_of_cards:
		cards.append(tool_data.get_duplicate())
	await _combat_main.add_tools_to_hand(cards, from_position, true)

func need_select_field() -> bool:
	return true