class_name ToolScriptMirrorPool
extends ToolScript

func apply_tool(main_game:MainGame, fields:Array, field_index:int, tool_data:ToolData) -> void:
	var action_data:ActionData = ActionData.new()
	var field:Field = fields[field_index]
	action_data.type = ActionData.ActionType.WATER
	action_data.value = field.plant.light.value
	var tool_card:GUIToolCardButton = main_game.gui_main_game.gui_tool_card_container.find_card(tool_data)
	await field.apply_action(action_data, tool_card)

func need_select_field() -> bool:
	return true