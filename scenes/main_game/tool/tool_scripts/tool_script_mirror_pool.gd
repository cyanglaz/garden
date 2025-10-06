class_name ToolScriptMirrorPool
extends ToolScript

func apply_tool(_main_game:MainGame, fields:Array, field_index:int, _tool_data:ToolData) -> void:
	var action_data:ActionData = ActionData.new()
	var field:Field = fields[field_index]
	action_data.type = ActionData.ActionType.WATER
	action_data.value = field.plant.light.value
	await field.apply_actions([action_data])

func need_select_field() -> bool:
	return true