class_name ToolScriptSustainability
extends ToolScript

func apply_tool(main_game:MainGame, fields:Array, field_index:int, _tool_data:ToolData) -> void:
	await main_game.update_power("sustainability", 1)
