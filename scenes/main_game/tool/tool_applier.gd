class_name ToolApplier
extends RefCounted

signal tool_application_started(tool_data:ToolData)
signal tool_application_completed(tool_data:ToolData)
signal _all_field_action_application_completed()

var _pending_actions:Array[ActionData] = []
var _action_index:int = 0
var _field_application_index_counter:int = 0

func apply_tool(combat_main:CombatMain, fields:Array, field_index:int, tool_data:ToolData, secondary_card_datas:Array, tool_card:GUIToolCardButton) -> void:
	tool_application_started.emit(tool_data)
	match tool_data.type:
		ToolData.Type.SKILL:
			if tool_data.tool_script:
				await tool_data.tool_script.apply_tool(combat_main, fields, field_index, tool_data, secondary_card_datas)
			else:
				_action_index = 0
				_pending_actions = tool_data.actions.duplicate()
				await _apply_next_action(combat_main, fields, field_index, tool_data, secondary_card_datas, tool_card)
		ToolData.Type.POWER:
			await combat_main.update_power(tool_data.id, 1)
	tool_application_completed.emit(tool_data)

func _apply_next_action(combat_main:CombatMain, fields:Array, field_index:int, tool_data:ToolData, secondary_card_datas:Array, tool_card:GUIToolCardButton) -> void:
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
			await _apply_field_tool_action(action, fields_to_apply, combat_main, tool_card)
		ActionData.ActionCategory.WEATHER:
			await _apply_weather_tool_action(action, combat_main)
		_:
			await _apply_instant_use_tool_action(action, combat_main, tool_data, secondary_card_datas)
	await _apply_next_action(combat_main, fields, field_index, tool_data, secondary_card_datas, tool_card)

func _apply_field_tool_action(action:ActionData, fields:Array, combat_main:CombatMain, _tool_card:GUIToolCardButton) -> void:
	_field_application_index_counter = fields.size()
	for field:Field in fields:
		field.action_application_completed.connect(_on_field_action_application_completed.bind(field))
		field.apply_actions([action], combat_main)
	await _all_field_action_application_completed

func _apply_weather_tool_action(action:ActionData, combat_main:CombatMain) -> void:
	var from_position := combat_main.gui.gui_tool_card_container.get_center_position()
	await combat_main.weather_manager.apply_weather_tool_action(action, from_position, combat_main)

func _apply_instant_use_tool_action(action:ActionData, combat_main:CombatMain, tool_data:ToolData, secondary_card_datas:Array) -> void:
	match action.type:
		ActionData.ActionType.DRAW_CARD:
			await combat_main.draw_cards(action.get_calculated_value(null))
		ActionData.ActionType.DISCARD_CARD:
			await _handle_discard_card_action(action, combat_main, tool_data, secondary_card_datas)
		ActionData.ActionType.ENERGY:
			combat_main.energy_tracker.restore(action.get_calculated_value(null))
		ActionData.ActionType.UPDATE_GOLD:
			await Singletons.main_game.update_gold(action.get_calculated_value(null), true)
		ActionData.ActionType.UPDATE_X:
			var x_action:ActionData
			for action_data:ActionData in tool_data.actions:
				if action_data.value_type == ActionData.ValueType.X:
					x_action = action_data
					break
			x_action.modified_x_value += action.get_calculated_value(null)

func _handle_discard_card_action(action:ActionData, combat_main:CombatMain, tool_data:ToolData, secondary_card_datas:Array) -> void:
	var random := action.value_type == ActionData.ValueType.RANDOM
	var discard_size := action.get_calculated_value(null)
	if random:
		var tool_datas_to_discard:Array = combat_main.tool_manager.discardable_cards()
		tool_datas_to_discard.erase(tool_data)
		if tool_datas_to_discard.is_empty():
			return
		secondary_card_datas= Util.unweighted_roll(tool_datas_to_discard, discard_size)
	await combat_main.discard_cards(secondary_card_datas)
	await combat_main.field_container.trigger_tool_discard_hook(discard_size)

func _on_field_action_application_completed(field:Field) -> void:
	field.action_application_completed.disconnect(_on_field_action_application_completed.bind(field))
	_field_application_index_counter -= 1
	if _field_application_index_counter == 0:
		_all_field_action_application_completed.emit()
