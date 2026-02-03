class_name ActionsApplier
extends RefCounted

var card_action_applier:CardActionApplier = CardActionApplier.new()
var plant_action_applier:PlantActionApplier = PlantActionApplier.new()
var player_action_applier:PlayerActionApplier = PlayerActionApplier.new()

var _pending_actions:Array = []
var _action_index:int = 0

func apply_actions(actions:Array, combat_main:CombatMain, secondary_card_datas:Array, tool_card:GUIToolCardButton) -> void:
	_pending_actions = _organize_actions_to_apply(actions)
	_action_index = 0
	await _apply_next_action(combat_main, secondary_card_datas, tool_card, _pending_actions.duplicate())

func _apply_next_action(combat_main:CombatMain, secondary_card_datas:Array, tool_card:GUIToolCardButton, all_actions:Array) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		return
	var action:ActionData = _pending_actions[_action_index]
	_action_index += 1
	match action.action_category:
		ActionData.ActionCategory.CARD:
			card_action_applier.apply_action(action, all_actions)
		ActionData.ActionCategory.FIELD:
			await plant_action_applier.apply_action(action, combat_main.get_current_player_plant(), combat_main)
		ActionData.ActionCategory.PLAYER:
			await player_action_applier.apply_action(action, combat_main, secondary_card_datas)
	await _apply_next_action(combat_main, secondary_card_datas, tool_card, all_actions)

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
