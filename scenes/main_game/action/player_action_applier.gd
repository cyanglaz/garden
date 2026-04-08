class_name PlayerActionApplier
extends RefCounted

signal action_application_completed()
signal _all_tool_datas_added_to_discard_pile()

var _tool_datas_added_to_discard_pile_count:int = 0

func apply_action(action:ActionData, combat_main:CombatMain, secondary_card_datas:Array) -> void:
	assert(action.action_category == ActionData.ActionCategory.PLAYER)
	var calculated_value := action.get_calculated_value(null)
	match action.type:
		ActionData.ActionType.DRAW_CARD:
			assert(calculated_value >= 0, "Draw card action value must be greater than 0")
			await combat_main.draw_cards(calculated_value)
		ActionData.ActionType.DISCARD_CARD:
			assert(calculated_value >= 0, "Discard card action value must be greater than 0")
			await _handle_discard_card_action(action, combat_main, secondary_card_datas)
		ActionData.ActionType.COMPOST:
			assert(calculated_value >= 0, "Compost action value must be greater than 0")
			await _handle_compost_action(action, combat_main, secondary_card_datas)
		ActionData.ActionType.ENERGY:
			Events.request_energy_update.emit(calculated_value, action.operator_type)
			await Util.create_scaled_timer(Constants.GLOBAL_UPGRADE_PAUSE_TIME).timeout
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
		ActionData.ActionType.UPDATE_HP:
			Events.request_hp_update.emit(calculated_value, action.operator_type)
			await Util.create_scaled_timer(Constants.GLOBAL_UPGRADE_PAUSE_TIME).timeout
		ActionData.ActionType.PUSH_LEFT:
			combat_main.player.current_field_index = max(combat_main.player.current_field_index - calculated_value, 0)
			await Util.create_scaled_timer(Constants.GLOBAL_UPGRADE_PAUSE_TIME).timeout
		ActionData.ActionType.PUSH_RIGHT:
			combat_main.player.current_field_index = min(combat_main.player.current_field_index + calculated_value, combat_main.player.max_plants_index)
			await Util.create_scaled_timer(Constants.GLOBAL_UPGRADE_PAUSE_TIME).timeout
		ActionData.ActionType.ADD_CARD_DISCARD_PILE:
			assert(calculated_value >= 0, "Add card discard pile action value must be greater than 0")
			await _handle_add_card_discard_pile_action(action.data["card_id"], calculated_value, combat_main)
		ActionData.ActionType.STUN, ActionData.ActionType.MOMENTUM:
			combat_main.player.player_status_container.update_player_upgrade(Util.get_action_id_with_action_type(action.type), calculated_value, action.operator_type)
			await Util.create_scaled_timer(Constants.GLOBAL_UPGRADE_PAUSE_TIME).timeout
		_:
			assert(false, "Invalid player action type: %s" % action.type)
	action_application_completed.emit()

func _handle_discard_card_action(_action:ActionData, combat_main:CombatMain, secondary_card_datas:Array) -> void:
	var discard_size := secondary_card_datas.size()
	if discard_size <= 0:
		await Util.await_for_tiny_time()
		return
	await combat_main.discard_cards(secondary_card_datas)
	await combat_main.plant_field_container.trigger_tool_discard_hook(discard_size)

func _handle_compost_action(_action:ActionData, combat_main:CombatMain, secondary_card_datas:Array) -> void:
	var discard_size := secondary_card_datas.size()
	if discard_size <= 0:
		await Util.await_for_tiny_time()
		return
	await combat_main.exhaust_cards(secondary_card_datas)

func _handle_add_card_discard_pile_action(card_id:String, count:int, combat_main:CombatMain) -> void:
	if count <= 0:
		return
	_tool_datas_added_to_discard_pile_count = count
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id(card_id).get_duplicate()
	var from_position:Vector2 = Util.get_node_canvas_position(combat_main) - GUIToolCardButton.SIZE / 2
	var tool_datas:Array = []
	for i in count:
		var tool_data_to_add:ToolData = tool_data.get_duplicate()
		tool_data_to_add.adding_to_deck_finished.connect(_on_tool_data_adding_to_deck_finished.bind(tool_data_to_add))
		tool_datas.append(tool_data_to_add)
	Events.request_add_tools_to_discard_pile.emit(tool_datas, from_position, true)
	await _all_tool_datas_added_to_discard_pile

func _on_tool_data_adding_to_deck_finished(tool_data_to_add:ToolData) -> void:
	tool_data_to_add.adding_to_deck_finished.disconnect(_on_tool_data_adding_to_deck_finished)
	_tool_datas_added_to_discard_pile_count -= 1
	if _tool_datas_added_to_discard_pile_count <= 0:
		_all_tool_datas_added_to_discard_pile.emit()