class_name ToolManager
extends RefCounted

signal tool_application_started()
signal tool_application_completed()

var tools:Array[ToolData]

var selected_tool_index:int = -1
var selected_tool:ToolData: get = _get_selected_tool

func select_tool(index:int) -> void:
	selected_tool_index = index

func apply_field_tool(field:Field) -> void:
	assert(selected_tool_index >= 0)
	var selected_tool_data:ToolData = tools[selected_tool_index]
	if selected_tool_data.need_select_field:
		if field.is_tool_applicable(selected_tool_data):
			tool_application_started.emit()
			field.tool_application_completed.connect(_on_tool_application_completed)
			field.apply_tool(selected_tool_data)

func apply_non_field_tool(main_game:MainGame) -> void:
	assert(selected_tool)
	for action:ActionData in selected_tool.actions:
		match action.action_category:
			ActionData.ActionCategory.WEATHER:
				main_game.weather_manager.apply_weather_tool_action(action)
			_:
				assert(false, "Invalid action category for instant use: " + str(action.action_category))
	tool_application_completed.emit(selected_tool)

func _on_tool_application_completed() -> void:
	tool_application_completed.emit(selected_tool)

func _get_selected_tool() -> ToolData:
	if selected_tool_index < 0:
		return null
	return tools[selected_tool_index]
