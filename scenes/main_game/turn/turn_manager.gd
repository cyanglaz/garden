class_name TurnManager
extends RefCounted

var turn:int = 0
var _tools:Array[ToolData]

func start_new(tools:Array[ToolData]) -> void:
	_tools = tools.duplicate()
	turn = 0

func start_turn() -> void:
	turn += 1
	for tool_data:ToolData in _tools:
		tool_data.cd_counter.restore(1)
