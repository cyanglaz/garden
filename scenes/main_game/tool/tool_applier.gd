class_name ToolApplier
extends RefCounted

signal tool_application_started(tool_data:ToolData)
signal tool_application_completed(tool_data:ToolData)
signal tool_application_error(tool_data:ToolData, error_message:String)

var _actions_applier:ActionsApplier = ActionsApplier.new()

func apply_tool(combat_main:CombatMain, tool_data:ToolData, tool_card:GUIToolCardButton, gui_tool_card_container:GUIToolCardContainer) -> void:
	tool_application_started.emit(tool_data)
	match tool_data.type:
		ToolData.Type.SKILL:
			if tool_data.tool_script:
				await _apply_tool_script(combat_main, tool_data, gui_tool_card_container)
			else:
				await _apply_actions(combat_main, tool_data, tool_card, gui_tool_card_container)
		ToolData.Type.POWER:
			combat_main.player.player_status_container.update_player_upgrade(tool_data.id, 1, ActionData.OperatorType.INCREASE)
			await Util.create_scaled_timer(Constants.GLOBAL_UPGRADE_PAUSE_TIME).timeout
	tool_application_completed.emit(tool_data)

func _apply_tool_script(combat_main:CombatMain, tool_data:ToolData, gui_tool_card_container:GUIToolCardContainer) -> void:
	var secondary_card_datas:Array = []
	assert(tool_data.tool_script, "Tool script is required to select secondary cards")
	var number_of_cards_to_select := tool_data.get_number_of_secondary_cards_to_select_from_script()
	if number_of_cards_to_select > 0:
		var selecting_from_cards = _get_secondary_cards_to_select_from(tool_data, gui_tool_card_container)
		var actual_number_of_cards_to_select = mini(number_of_cards_to_select, selecting_from_cards.size())
		if actual_number_of_cards_to_select < number_of_cards_to_select:
			if tool_data.get_card_selection_type_from_script() == ActionData.CardSelectionType.RESTRICTED:
				gui_tool_card_container.animate_card_error_shake(tool_data)
				tool_application_error.emit(tool_data, tool_data.get_card_selection_custom_error_message())
				return
		else:
			if tool_data.get_is_random_secondary_card_selection_from_script():
				secondary_card_datas = Util.unweighted_roll(selecting_from_cards, actual_number_of_cards_to_select)
			else:
				# Some actions need to select cards, for example discard, compost
				secondary_card_datas = await gui_tool_card_container.select_secondary_cards(actual_number_of_cards_to_select, selecting_from_cards)
	await tool_data.tool_script.apply_tool(combat_main, tool_data, secondary_card_datas)

func _apply_actions(combat_main:CombatMain, tool_data:ToolData, tool_card:GUIToolCardButton, gui_tool_card_container:GUIToolCardContainer) -> void:
	var all_other_cards:Array = _get_secondary_cards_to_select_from(tool_data, gui_tool_card_container)
	await _actions_applier.apply_actions(tool_data.actions, combat_main, tool_card, all_other_cards, gui_tool_card_container)

func _get_secondary_cards_to_select_from(tool_data:ToolData, gui_tool_card_container:GUIToolCardContainer) -> Array:
	var selecting_from_cards:Array = []
	for card in gui_tool_card_container.get_all_cards():
		if card.tool_data != tool_data:
			selecting_from_cards.append(card.tool_data)
	selecting_from_cards.erase(tool_data)
	if tool_data.tool_script && tool_data.tool_script.secondary_card_selection_filter():
		var filter:Callable = tool_data.tool_script.secondary_card_selection_filter()
		selecting_from_cards = selecting_from_cards.filter(filter)
	return selecting_from_cards