class_name ToolScriptMirrorPool
extends ToolScript

func apply_tool(_main_game:MainGame, field:Field, _tool_data:ToolData) -> void:
	var action_data:ActionData = ActionData.new()
	action_data.type = ActionData.ActionType.WATER
	action_data.value = field.plant.light.value
	await field.apply_actions([action_data])
