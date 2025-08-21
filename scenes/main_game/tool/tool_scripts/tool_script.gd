class_name ToolScript
extends RefCounted

func apply_tool(_main_game:MainGame, _field:Field, _tool_data:ToolData) -> void:
	await Util.await_for_tiny_time()
