class_name PlayerActionApplier
extends RefCounted

signal action_application_completed()

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
		ActionData.ActionType.ENERGY:
			match action.operator_type:
				ActionData.OperatorType.INCREASE:
					combat_main.energy_tracker.restore(calculated_value)
					combat_main.player.push_state("PlayerStateUpgradeEnergy")
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
		ActionData.ActionType.UPDATE_MOVEMENT:
			var real_value := calculated_value
			match action.operator_type:
				ActionData.OperatorType.INCREASE:
					real_value = calculated_value
					combat_main.player.play_upgrade_animation()
				ActionData.OperatorType.DECREASE:
					real_value = -calculated_value
				ActionData.OperatorType.EQUAL_TO:
					real_value = calculated_value
			combat_main.player.moves_left += real_value
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
