class_name ToolScriptBottledWater
extends ToolScript

var _card_spawn_position:Vector2

func apply_tool(_main_game:MainGame, fields:Array, field_index:int, tool_data:ToolData, _secondary_card_datas:Array) -> void:
	var action_data:ActionData = ActionData.new()
	var field:Field = fields[field_index]
	action_data.type = ActionData.ActionType.WATER
	var gain := tool_data.data["gain"] as int
	action_data.value = gain
	_card_spawn_position = Util.get_node_ui_position(Singletons.main_game.gui_main_game.gui_tool_card_container, field.plant) - GUIToolCardButton.SIZE / 2
	await field.apply_actions([action_data], null)

func need_select_field() -> bool:
	return true

func handle_post_application_hook(_tool_data:ToolData) -> void:
	var empty_bottled_tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("empty_bottle").get_duplicate()
	await Singletons.main_game.tool_manager.add_temp_tools_to_discard_pile([empty_bottled_tool_data], _card_spawn_position, false)
