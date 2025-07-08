class_name ToolManager
extends RefCounted

signal tool_application_started()
signal tool_application_failed()
signal tool_application_completed()

var tools:Array[ToolData]

var selected_tool_index:int = -1
var selected_tool:ToolData: get = _get_selected_tool

var _tool_applier:ToolApplier = ToolApplier.new()

func _init() -> void:
	_tool_applier.tool_application_started.connect(func(): tool_application_started.emit())
	_tool_applier.tool_application_failed.connect(func(): tool_application_failed.emit())
	_tool_applier.tool_application_completed.connect(func(): tool_application_completed.emit(selected_tool))

func select_tool(index:int) -> void:
	selected_tool_index = index

func apply_tool(main_game:MainGame, field:Field) -> void:
	_tool_applier.apply_tool(main_game, field, selected_tool, selected_tool_index)

func _get_selected_tool() -> ToolData:
	if selected_tool_index < 0:
		return null
	return tools[selected_tool_index]
