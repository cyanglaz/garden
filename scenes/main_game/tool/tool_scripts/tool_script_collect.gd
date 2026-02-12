class_name ToolScriptCollect
extends ToolScript

func apply_tool(combat_main:CombatMain, _tool_data:ToolData, _secondary_card_datas:Array) -> void:
	var action_data:ActionData = ActionData.new()
	var plant:Plant = combat_main.get_current_player_plant()
	action_data.type = ActionData.ActionType.WATER
	var water_to_reduce := plant.water.value
	action_data.operator_type = ActionData.OperatorType.EQUAL_TO
	action_data.value = 0
	await plant.apply_actions([action_data])

	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("runoff").get_duplicate()
	var from_position:Vector2 = Util.get_node_canvas_position(plant) - GUIToolCardButton.SIZE / 2
	var number_of_cards := water_to_reduce * (_tool_data.data["gain"] as int)
	var cards:Array = []
	for i in number_of_cards:
		cards.append(tool_data.get_duplicate())
	await combat_main.add_tools_to_hand(cards, from_position, true)

func need_select_field() -> bool:
	return true

func has_field_action() -> bool:
	return true
