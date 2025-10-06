class_name ToolApplier
extends RefCounted

signal tool_application_started(tool_data:ToolData)
signal tool_application_completed(tool_data:ToolData)
signal _all_field_action_application_completed()

var _pending_actions:Array[ActionData] = []
var _action_index:int = 0
var _field_application_index_counter:int = 0

func apply_tool(main_game:MainGame, fields:Array, field_index:int, tool_data:ToolData, tool_card:GUIToolCardButton) -> void:
	tool_application_started.emit(tool_data)
	if tool_data.tool_script:
		await tool_data.tool_script.apply_tool(main_game, fields, field_index, tool_data)
		tool_application_completed.emit(tool_data)
	else:
		_action_index = 0
		_pending_actions = tool_data.actions.duplicate()
		await _apply_next_action(main_game, fields, field_index, tool_data, tool_card)

func _apply_next_action(main_game:MainGame, fields:Array, field_index:int, tool_data:ToolData, tool_card:GUIToolCardButton) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		tool_application_completed.emit(tool_data)
		return
	var action:ActionData = _pending_actions[_action_index]
	_action_index += 1
	match action.action_category:
		ActionData.ActionCategory.FIELD:
			var fields_to_apply:Array = []
			if action.specials.has(ActionData.Special.ALL_FIELDS):
				fields_to_apply = fields
			else:
				fields_to_apply.append(fields[field_index])
			fields_to_apply.filter(func(field:Field): return field.is_action_applicable(action))
			await _apply_field_tool_action(action, fields_to_apply, tool_card)
		ActionData.ActionCategory.WEATHER:
			await _apply_weather_tool_action(action, main_game)
		_:
			await _apply_instant_use_tool_action(action, main_game, tool_data)
	await _apply_next_action(main_game, fields, field_index, tool_data, tool_card)

func _apply_field_tool_action(action:ActionData, fields:Array, tool_card:GUIToolCardButton) -> void:
	_field_application_index_counter = fields.size()
	for field:Field in fields:
		field.action_application_completed.connect(_on_field_action_application_completed.bind(field))
		field.apply_action(action, tool_card)
	await _all_field_action_application_completed

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
		var tool_datas_to_discard:Array = main_game.tool_manager.discardable_cards()
		tool_datas_to_discard.erase(tool_data)
		if tool_datas_to_discard.is_empty():
			return
		var random_tools := Util.unweighted_roll(tool_datas_to_discard, discard_size)
		await main_game.discard_cards(random_tools)
		await main_game.field_container.trigger_tool_discard_hook(discard_size)
	else:
		assert(false, "TODO: create manual discard flow")

func _on_field_action_application_completed(field:Field) -> void:
	field.action_application_completed.disconnect(_on_field_action_application_completed.bind(field))
	_field_application_index_counter -= 1
	if _field_application_index_counter == 0:
		_all_field_action_application_completed.emit()
