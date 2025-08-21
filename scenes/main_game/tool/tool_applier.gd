class_name ToolApplier
extends RefCounted

signal tool_application_started(tool_index:int)
signal tool_application_completed()

var _pending_actions:Array[ActionData] = []
var _action_index:int = 0

func apply_tool(main_game:MainGame, field:Field, tool_data:ToolData, tool_index:int) -> void:
	tool_application_started.emit(tool_index)
	if tool_data.tool_script:
		await tool_data.tool_script.apply_tool(main_game, field, tool_data, tool_index)
		tool_application_completed.emit()
	else:
		_action_index = 0
		_pending_actions = tool_data.actions.duplicate()
		await _apply_next_action(main_game, field, tool_index)

func _apply_next_action(main_game:MainGame, field:Field, tool_index:int) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		tool_application_completed.emit()
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
			await _apply_instant_use_tool_action(action, main_game, tool_index)
	await _apply_next_action(main_game, field, tool_index)

func _apply_field_tool_action(action:ActionData, field:Field) -> void:
	await field.apply_actions([action])

func _apply_weather_tool_action(action:ActionData, main_game:MainGame, tool_index:int) -> void:
	var tool_card_position := main_game.gui_main_game.gui_tool_card_container.get_card_position(tool_index)
	var weather_icon_position := main_game.gui_main_game.gui_weather_container.get_today_weather_icon().global_position
	await main_game.weather_manager.apply_weather_tool_action(action, tool_card_position, weather_icon_position)

func _apply_instant_use_tool_action(action:ActionData, main_game:MainGame, _tool_index:int) -> void:
	match action.type:
		ActionData.ActionType.DRAW_CARD:
			await main_game.draw_cards(action.value)
		ActionData.ActionType.DISCARD_CARD:
			await _handle_discard_card_action(action, main_game, _tool_index)

func _handle_discard_card_action(action:ActionData, main_game:MainGame, _tool_index:int) -> void:
	var random := action.value_type == ActionData.ValueType.RANDOM
	var discard_size := action.value
	if random:
		var indices := []
		for i in main_game.tool_manager.tool_deck.hand.size():
			indices.append(i)
		if indices.size() == 0:
			return
		if indices.size() < discard_size:
			discard_size = indices.size()
		var random_indices := Util.unweighted_roll(indices, discard_size)
		await main_game.discard_cards(random_indices)
	else:
		assert(false, "TODO: create manual discard flow")
