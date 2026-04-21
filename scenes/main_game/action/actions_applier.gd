class_name ActionsApplier
extends RefCounted

var card_action_applier:CardActionApplier = CardActionApplier.new()
var plant_action_applier:PlantActionApplier = PlantActionApplier.new()
var player_action_applier:PlayerActionApplier = PlayerActionApplier.new()

var _pending_actions:Array = []
var _action_index:int = 0

func queue_actions(actions:Array, combat_main:CombatMain, tool_card:GUIToolCardButton, gui_tool_card_container:GUIToolCardContainer) -> void:
	var all_actions:Array = _organize_actions_to_apply(actions)
	for action in all_actions:
		var request = CombatQueueRequest.new()
		request.callback = func(_cm: CombatMain) -> void: await _apply_action(action, combat_main, tool_card, all_actions, gui_tool_card_container)
		Events.request_combat_queue_push.emit(request)

func _apply_action(action:ActionData, combat_main:CombatMain, tool_card:GUIToolCardButton, all_actions:Array, gui_tool_card_container:GUIToolCardContainer) -> void:
	var secondary_card_datas:Array = await _get_secondary_card_datas_from_action(action, tool_card, gui_tool_card_container, combat_main)
	match action.action_category:
		ActionData.ActionCategory.CARD:
			card_action_applier.apply_action(action, all_actions, combat_main)
		ActionData.ActionCategory.FIELD:
			await plant_action_applier.apply_action(action, combat_main.get_current_player_plant(), combat_main)
		ActionData.ActionCategory.PLAYER:
			await player_action_applier.apply_action(action, combat_main, secondary_card_datas)

func apply_actions(actions:Array, combat_main:CombatMain, tool_card:GUIToolCardButton, gui_tool_card_container:GUIToolCardContainer) -> void:
	_pending_actions = _organize_actions_to_apply(actions)
	_action_index = 0
	await _apply_next_action(combat_main, tool_card, _pending_actions.duplicate(), gui_tool_card_container)

func _apply_next_action(combat_main:CombatMain, tool_card:GUIToolCardButton, all_actions:Array, gui_tool_card_container:GUIToolCardContainer) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		return
	var action:ActionData = _pending_actions[_action_index]
	_action_index += 1
	var secondary_card_datas:Array = await _get_secondary_card_datas_from_action(action, tool_card, gui_tool_card_container, combat_main)
	match action.action_category:
		ActionData.ActionCategory.CARD:
			card_action_applier.apply_action(action, all_actions, combat_main)
		ActionData.ActionCategory.FIELD:
			await plant_action_applier.apply_action(action, combat_main.get_current_player_plant(), combat_main)
		ActionData.ActionCategory.PLAYER:
			await player_action_applier.apply_action(action, combat_main, secondary_card_datas)
	await _apply_next_action(combat_main, tool_card, all_actions, gui_tool_card_container)

func _get_secondary_card_datas_from_action(action:ActionData, gui_card:GUIToolCardButton, gui_tool_card_container:GUIToolCardContainer, combat_main:CombatMain) -> Array:
	if !action.need_card_selection:
		return []
	var number_of_cards_to_select := action.get_calculated_value(combat_main)
	var secondary_card_datas:Array = []
	if action.value_type == ActionData.ValueType.RANDOM:
		var selecting_from_cards:Array = combat_main.tool_manager.tool_deck.hand.filter(func(card:ToolData): return card != gui_card.tool_data)
		var actual_number_of_cards_to_select = mini(number_of_cards_to_select, selecting_from_cards.size())
		secondary_card_datas = Util.unweighted_roll(selecting_from_cards, actual_number_of_cards_to_select)
	else:
		# Some actions need to select cards, for example discard, compost
		var candidates:Array = combat_main.tool_manager.tool_deck.hand.duplicate().filter(func(card:ToolData): return card != gui_card.tool_data)
		secondary_card_datas = await gui_tool_card_container.select_secondary_cards(number_of_cards_to_select, gui_card.tool_data, candidates)
	return secondary_card_datas

func _organize_actions_to_apply(actions:Array) -> Array:
	var loop_action_index:int = Util.array_find(actions, func(action:ActionData): return action.type == ActionData.ActionType.LOOP)
	if loop_action_index == -1:
		return actions.duplicate()
	var loop_action:ActionData = actions[loop_action_index]
	var loop_value:int = loop_action.value
	var actions_to_apply:Array = []
	var actions_to_loop:Array = actions.slice(0, loop_action_index)
	for i in loop_value:
		actions_to_apply.append_array(actions_to_loop.duplicate())
	var actions_after_loop:Array = actions.slice(loop_action_index + 1)
	actions_to_apply.append_array(actions_after_loop)
	return actions_to_apply
