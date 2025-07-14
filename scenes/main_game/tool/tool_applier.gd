class_name ToolApplier
extends RefCounted

signal tool_application_started(tool_index:int)
signal tool_application_failed(tool_index:int)
signal tool_application_completed(tool_index:int)

var _pending_actions:Array[ActionData] = []
var _action_index:int = 0

func apply_tool(main_game:MainGame, field:Field, tool_data:ToolData, tool_index:int) -> void:
	if tool_data.need_select_field && !field.is_tool_applicable(tool_data):
		tool_application_failed.emit(tool_index)
		return
	_action_index = 0
	_pending_actions = tool_data.actions.duplicate()
	tool_application_started.emit(tool_index)
	_apply_next_action(main_game, field, tool_index)

func _apply_next_action(main_game:MainGame, field:Field, tool_index:int) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		tool_application_completed.emit(tool_index)
		return
	var action:ActionData = _pending_actions[_action_index]
	_action_index += 1
	match action.action_category:
		ActionData.ActionCategory.FIELD:
			if field.is_action_applicable(action):
				await _apply_field_tool_action(action, field)
		ActionData.ActionCategory.WEATHER:
			await _apply_weather_tool_action(action, main_game, tool_index)
		_:
			assert(false, "Invalid action category for instant use: " + str(action.action_category))
	_apply_next_action(main_game, field, tool_index)

func _apply_field_tool_action(action:ActionData, field:Field) -> void:
	await field.apply_actions([action])

func _apply_weather_tool_action(action:ActionData, main_game:MainGame, tool_index:int) -> void:
	var tool_card_position := main_game.gui_main_game.gui_tool_card_container.get_card_position(tool_index)
	var weather_icon_position := main_game.gui_main_game.gui_weather_container.get_today_weather_icon().global_position
	await main_game.weather_manager.apply_weather_tool_action(action, tool_card_position, weather_icon_position)
