class_name ToolApplier
extends RefCounted

var _actions_applier:ActionsApplier = ActionsApplier.new()

func can_tool_be_applied(tool_data:ToolData, hand:Array) -> bool:
	if !tool_data.tool_script:
		return true
	if tool_data.get_card_selection_type_from_script() != ActionData.CardSelectionType.RESTRICTED:
		return true
	var number_of_cards_to_select := tool_data.get_number_of_secondary_cards_to_select_from_script()
	if number_of_cards_to_select == 0:
		return true
	var selecting_from_cards:Array = hand.filter(tool_data.tool_script.secondary_card_selection_filter())
	var actual_number_of_cards_to_select = mini(number_of_cards_to_select, selecting_from_cards.size())
	if actual_number_of_cards_to_select < number_of_cards_to_select:
		return false
	return true

func queue_tool_application(combat_main:CombatMain, tool_data:ToolData, gui_tool_card:GUIToolCardButton, gui_tool_card_container:GUIToolCardContainer) -> void:
	match tool_data.type:
		ToolData.Type.SKILL:
			if tool_data.tool_script:
				var request = CombatQueueRequest.new()
				request.callback = func(_cm: CombatMain) -> void: await _apply_tool_script(combat_main, tool_data, gui_tool_card_container)
				Events.request_combat_queue_push.emit(request)
			else:
				_actions_applier.queue_actions(tool_data.actions, combat_main, gui_tool_card, gui_tool_card_container)
		ToolData.Type.POWER:
			var request = CombatQueueRequest.new()
			request.callback = func(_cm: CombatMain) -> void: 
				combat_main.player.player_status_container.update_player_upgrade(tool_data.id, 1, ActionData.OperatorType.INCREASE)
				await Util.create_scaled_timer(Constants.GLOBAL_UPGRADE_PAUSE_TIME).timeout
			Events.request_combat_queue_push.emit(request)

func _apply_tool_script(combat_main:CombatMain, tool_data:ToolData, gui_tool_card_container:GUIToolCardContainer) -> bool:
	var secondary_card_datas:Array = []
	assert(tool_data.tool_script, "Tool script is required to select secondary cards")
	var number_of_cards_to_select := tool_data.get_number_of_secondary_cards_to_select_from_script()
	if number_of_cards_to_select > 0:
		var selecting_from_cards:Array = gui_tool_card_container.get_all_cards().filter(func(card:GUIToolCardButton): return card.tool_data != tool_data).map(func(card:GUIToolCardButton): return card.tool_data).filter(tool_data.tool_script.secondary_card_selection_filter())
		var actual_number_of_cards_to_select = mini(number_of_cards_to_select, selecting_from_cards.size())
		if tool_data.get_is_random_secondary_card_selection_from_script():
			secondary_card_datas = Util.unweighted_roll(selecting_from_cards, actual_number_of_cards_to_select)
		else:
			# Some actions need to select cards, for example discard, compost
			var candidates:Array = combat_main.tool_manager.tool_deck.hand.filter(tool_data.tool_script.secondary_card_selection_filter())
			secondary_card_datas = await gui_tool_card_container.select_secondary_cards(actual_number_of_cards_to_select, tool_data, candidates)
	await tool_data.tool_script.apply_tool(combat_main, tool_data, secondary_card_datas)
	return true
