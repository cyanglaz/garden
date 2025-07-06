class_name ToolManager
extends RefCounted

signal tool_application_started()
signal tool_application_field()
signal tool_application_completed()

var tools:Array[ToolData]

var selected_tool_index:int = -1
var selected_tool:ToolData: get = _get_selected_tool

var _pending_actions:Array[ActionData] = []
var _action_index:int = 0

func select_tool(index:int) -> void:
	selected_tool_index = index

func apply_tool(main_game:MainGame, field:Field) -> void:
	assert(selected_tool)
	_action_index = 0
	_pending_actions = selected_tool.actions.duplicate()
	tool_application_started.emit()
	_apply_next_action(main_game, field)

func _apply_next_action(main_game:MainGame, field:Field) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		tool_application_completed.emit(selected_tool)
		return
	var action:ActionData = _pending_actions[_action_index]
	_action_index += 1
	match action.action_category:
		ActionData.ActionCategory.FIELD:
			if field.is_tool_applicable(selected_tool):
				_apply_field_tool_action(action, main_game, field)
		ActionData.ActionCategory.WEATHER:
			_apply_weather_tool_action(action, main_game, field)
		_:
			assert(false, "Invalid action category for instant use: " + str(action.action_category))

func _apply_field_tool_action(action:ActionData, main_game:MainGame, field:Field) -> void:
	if field.is_tool_applicable(selected_tool):
		await field.apply_actions([action])
		_apply_next_action(main_game, field)
	else:
		tool_application_field.emit()

func _apply_weather_tool_action(action:ActionData, main_game:MainGame, field:Field) -> void:
	await main_game.weather_manager.apply_weather_tool_action(action)
	_apply_next_action(main_game, field)

func _get_selected_tool() -> ToolData:
	if selected_tool_index < 0:
		return null
	return tools[selected_tool_index]
