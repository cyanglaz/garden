class_name ToolApplier
extends RefCounted

signal tool_application_started(tool_data:ToolData)
signal tool_application_completed(tool_data:ToolData)
signal _all_plant_action_application_completed()

var _pending_actions:Array[ActionData] = []
var _action_index:int = 0
var _plant_application_index_counter:int = 0

func apply_tool(combat_main:CombatMain, plants:Array, plant_index:int, tool_data:ToolData, secondary_card_datas:Array, tool_card:GUIToolCardButton) -> void:
	tool_application_started.emit(tool_data)
	match tool_data.type:
		ToolData.Type.SKILL:
			if tool_data.tool_script:
				await tool_data.tool_script.apply_tool(combat_main, plants, plant_index, tool_data, secondary_card_datas)
			else:
				_action_index = 0
				_pending_actions = tool_data.actions.duplicate()
				await _apply_next_action(combat_main, plants, plant_index, tool_data, secondary_card_datas, tool_card)
		ToolData.Type.POWER:
			await combat_main.update_power(tool_data.id, 1)
	tool_application_completed.emit(tool_data)

func _apply_next_action(combat_main:CombatMain, plants:Array, plant_index:int, tool_data:ToolData, secondary_card_datas:Array, tool_card:GUIToolCardButton) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		tool_application_completed.emit(tool_data)
		return
	var action:ActionData = _pending_actions[_action_index]
	_action_index += 1
	match action.action_category:
		ActionData.ActionCategory.FIELD:
			var plants_to_apply:Array = []
			if action.specials.has(ActionData.Special.ALL_FIELDS):
				plants_to_apply = plants
				plants_to_apply = plants_to_apply.filter(func(plant:Plant): return !plant.is_bloom())
			else:
				plants_to_apply.append(plants[plant_index])
			await _apply_plant_tool_action(action, plants_to_apply, tool_card)
		ActionData.ActionCategory.WEATHER:
			await _apply_weather_tool_action(action, combat_main)
		_:
			await _apply_instant_use_tool_action(action, combat_main, tool_data, secondary_card_datas)
	await _apply_next_action(combat_main, plants, plant_index, tool_data, secondary_card_datas, tool_card)

func _apply_plant_tool_action(action:ActionData, plants:Array, _tool_card:GUIToolCardButton) -> void:
	_plant_application_index_counter = plants.size()
	for plant:Plant in plants:
		plant.action_application_completed.connect(_on_plant_action_application_completed.bind(plant))
		plant.apply_actions([action])
	await _all_plant_action_application_completed

func _apply_weather_tool_action(action:ActionData, combat_main:CombatMain) -> void:
	var from_position := combat_main.gui.gui_tool_card_container.get_center_position()
	await combat_main.weather_main.apply_weather_tool_action(action, from_position, combat_main)

func _apply_instant_use_tool_action(action:ActionData, combat_main:CombatMain, tool_data:ToolData, secondary_card_datas:Array) -> void:
	var calculated_value := action.get_calculated_value(null)
	match action.type:
		ActionData.ActionType.DRAW_CARD:
			assert(calculated_value >= 0, "Draw card action value must be greater than 0")
			await combat_main.draw_cards(calculated_value)
		ActionData.ActionType.DISCARD_CARD:
			assert(calculated_value >= 0, "Discard card action value must be greater than 0")
			await _handle_discard_card_action(action, combat_main, tool_data, secondary_card_datas)
		ActionData.ActionType.ENERGY:
			match action.operator_type:
				ActionData.OperatorType.INCREASE:
					combat_main.energy_tracker.restore(calculated_value)
				ActionData.OperatorType.DECREASE:
					combat_main.energy_tracker.spend(calculated_value)
				ActionData.OperatorType.EQUAL_TO:
					combat_main.energy_tracker.value = calculated_value
		ActionData.ActionType.UPDATE_GOLD:
			var real_value := calculated_value
			match action.operator_type:
				ActionData.OperatorType.INCREASE:
					real_value = calculated_value
				ActionData.OperatorType.DECREASE:
					real_value = -calculated_value
				ActionData.OperatorType.EQUAL_TO:
					real_value = calculated_value
			Events.request_update_gold.emit(real_value, true)
		ActionData.ActionType.UPDATE_X:
			var x_action:ActionData
			for action_data:ActionData in tool_data.actions:
				if action_data.value_type == ActionData.ValueType.X:
					x_action = action_data
					break
			match action.operator_type:
				ActionData.OperatorType.INCREASE:
					x_action.modified_x_value += calculated_value
				ActionData.OperatorType.DECREASE:
					x_action.modified_x_value -= calculated_value
				ActionData.OperatorType.EQUAL_TO:
					x_action.modified_x_value = calculated_value
		ActionData.ActionType.UPDATE_HP:
			var real_value := calculated_value
			match action.operator_type:
				ActionData.OperatorType.INCREASE:
					real_value = calculated_value
				ActionData.OperatorType.DECREASE:
					real_value = -calculated_value
				ActionData.OperatorType.EQUAL_TO:
					real_value = calculated_value
			Events.request_hp_update.emit(real_value)

func _handle_discard_card_action(_action:ActionData, combat_main:CombatMain, _tool_data:ToolData, secondary_card_datas:Array) -> void:
	var discard_size := secondary_card_datas.size()
	if discard_size <= 0:
		await Util.await_for_tiny_time()
		return
	await combat_main.discard_cards(secondary_card_datas)
	await combat_main.plant_field_container.trigger_tool_discard_hook(discard_size)

func _on_plant_action_application_completed(plant:Plant) -> void:
	plant.action_application_completed.disconnect(_on_plant_action_application_completed.bind(plant))
	_plant_application_index_counter -= 1
	if _plant_application_index_counter == 0:
		_all_plant_action_application_completed.emit()
