class_name ToolApplier
extends RefCounted

signal tool_application_started(tool_data:ToolData)
signal tool_application_completed(tool_data:ToolData)

var _pending_actions:Array[ActionData] = []
var _action_index:int = 0

func apply_tool(main_game:MainGame, field:Field, tool_data:ToolData) -> void:
	tool_application_started.emit(tool_data)
	if tool_data.tool_script:
		await tool_data.tool_script.apply_tool(main_game, field, tool_data)
		tool_application_completed.emit(tool_data)
	else:
		_action_index = 0
		_pending_actions = tool_data.actions.duplicate()
		await _apply_next_action(main_game, field, tool_data)

func _apply_next_action(main_game:MainGame, field:Field, tool_data:ToolData) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		tool_application_completed.emit(tool_data)
		return
	var action:ActionData = _pending_actions[_action_index]
	_action_index += 1
	match action.action_category:
		ActionData.ActionCategory.FIELD:
			if field.is_action_applicable(action):
				await _apply_field_tool_action(action, field)
		ActionData.ActionCategory.WEATHER:
			await _apply_weather_tool_action(action, main_game)
		_:
			await _apply_instant_use_tool_action(action, main_game, tool_data)
	await _apply_next_action(main_game, field, tool_data)

func _apply_field_tool_action(action:ActionData, field:Field) -> void:
	await field.apply_actions([action])

func _apply_weather_tool_action(action:ActionData, main_game:MainGame) -> void:
	var from_position := main_game.gui_main_game.gui_tool_card_container.get_center_position()
	var weather_icon_position := main_game.gui_main_game.gui_weather_container.get_today_weather_icon().global_position
	await main_game.weather_manager.apply_weather_tool_action(action, from_position, weather_icon_position)

func _apply_instant_use_tool_action(action:ActionData, main_game:MainGame, tool_data:ToolData) -> void:
	match action.type:
		ActionData.ActionType.DRAW_CARD:
			await main_game.draw_cards(action.value)
		ActionData.ActionType.DISCARD_CARD:
			await _handle_discard_card_action(action, main_game, tool_data)

func _handle_discard_card_action(action:ActionData, main_game:MainGame, tool_data:ToolData) -> void:
	var random := action.value_type == ActionData.ValueType.RANDOM
	var discard_size := action.value
	if random:
		var tool_datas_to_discard:Array = main_game.tool_manager.tool_deck.hand.duplicate()
		tool_datas_to_discard.erase(tool_data)
		if tool_datas_to_discard.is_empty():
			return
		var random_tools := Util.unweighted_roll(tool_datas_to_discard, discard_size)
		await main_game.discard_cards(random_tools)
	else:
		assert(false, "TODO: create manual discard flow")
