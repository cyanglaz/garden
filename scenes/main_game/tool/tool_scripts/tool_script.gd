@abstract
class_name ToolScript
extends RefCounted

func apply_tool(_main_game:MainGame, _fields:Array, _field_index:int, _tool_data:ToolData) -> void:
	await Util.await_for_tiny_time()

func need_select_field() -> bool:
	assert(false, "need_select_field is not implemented")
	return false