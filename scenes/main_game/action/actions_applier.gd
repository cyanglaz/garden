class_name ActionsApplier
extends RefCounted

var card_action_applier:CardActionApplier = CardActionApplier.new()
var plant_action_applier:PlantActionApplier = PlantActionApplier.new()
var player_action_applier:PlayerActionApplier = PlayerActionApplier.new()
var weather_action_applier:WeatherActionApplier = WeatherActionApplier.new()

var _pending_actions:Array[ActionData] = []
var _action_index:int = 0

func apply_actions(actions:Array, combat_main:CombatMain, plants:Array, plant_index:int, tool_data:ToolData, secondary_card_datas:Array, tool_card:GUIToolCardButton) -> void:
	_pending_actions = actions.duplicate()
	_action_index = 0
	await _apply_next_action(combat_main, plants, plant_index, tool_data, secondary_card_datas, tool_card)

func _apply_next_action(combat_main:CombatMain, plants:Array, plant_index:int, tool_data:ToolData, secondary_card_datas:Array, tool_card:GUIToolCardButton) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		return
	var action:ActionData = _pending_actions[_action_index]
	_action_index += 1
	match action.action_category:
		ActionData.ActionCategory.CARD:
			card_action_applier.apply_action(action, tool_data)
		ActionData.ActionCategory.FIELD:
			await plant_action_applier.apply_action(action, plants, plant_index)
		ActionData.ActionCategory.PLAYER:
			await player_action_applier.apply_action(action, combat_main, secondary_card_datas)
		ActionData.ActionCategory.WEATHER:
			await weather_action_applier.apply_action(action, combat_main)
	await _apply_next_action(combat_main, plants, plant_index, tool_data, secondary_card_datas, tool_card)
