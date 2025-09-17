@abstract
class_name ToolScript
extends RefCounted

func apply_tool(_main_game:MainGame, _fields:Array, _field_index:int, _tool_data:ToolData) -> void:
	await Util.await_for_tiny_time()
