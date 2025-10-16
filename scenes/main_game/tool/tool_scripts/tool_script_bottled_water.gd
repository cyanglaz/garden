class_name ToolScriptBottledWater
extends ToolScript

func apply_tool(_main_game:MainGame, fields:Array, field_index:int, tool_data:ToolData, _secondary_card_datas:Array) -> void:
	var action_data:ActionData = ActionData.new()
	var field:Field = fields[field_index]
	action_data.type = ActionData.ActionType.WATER
	var gain := tool_data.data["gain"] as int
	action_data.value = gain
	await field.apply_actions([action_data], null)

func need_select_field() -> bool:
	return true

func handle_post_application_hook(_tool_data:ToolData) -> void:
	var empty_bottled_tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("empty_bottle").get_duplicate()
	await Singletons.main_game.add_temp_tools_to_hand([empty_bottled_tool_data], Vector2.ZERO, false)
