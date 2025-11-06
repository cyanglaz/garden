class_name ToolScriptBottledWater
extends ToolScript

var _card_spawn_position:Vector2

func apply_tool(combat_main:CombatMain, plants:Array, field_index:int, tool_data:ToolData, _secondary_card_datas:Array) -> void:
	var action_data:ActionData = ActionData.new()
	var plant:Plant = plants[field_index]
	action_data.type = ActionData.ActionType.WATER
	var gain := tool_data.data["gain"] as int
	action_data.value = gain
	_card_spawn_position = Util.get_node_canvas_position(plant) - GUIToolCardButton.SIZE / 2
	await plant.apply_actions([action_data], combat_main)

func need_select_field() -> bool:
	return true

func handle_post_application_hook(_tool_data:ToolData, combat_main:CombatMain) -> void:
	var empty_bottled_tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("empty_bottle").get_duplicate()
	await combat_main.tool_manager.add_tools_to_discard_pile([empty_bottled_tool_data], _card_spawn_position, false)
