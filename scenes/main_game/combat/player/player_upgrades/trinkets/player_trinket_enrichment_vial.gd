class_name PlayerTrinketEnrichmentVial
extends PlayerTrinket

var _last_triggered_turn := -1

func _has_discard_hook(combat_main: CombatMain, _tool_datas: Array) -> bool:
	return combat_main.day_manager.day != _last_triggered_turn

func _handle_discard_hook(combat_main: CombatMain, _tool_datas: Array) -> void:
	_last_triggered_turn = combat_main.day_manager.day
	var plant: Plant = combat_main.get_current_player_plant()
	var light_action := ActionData.new()
	light_action.type = ActionData.ActionType.LIGHT
	light_action.operator_type = ActionData.OperatorType.INCREASE
	light_action.value = int(data.data[&"light"])
	var water_action := ActionData.new()
	water_action.type = ActionData.ActionType.WATER
	water_action.operator_type = ActionData.OperatorType.INCREASE
	water_action.value = int(data.data[&"water"])
	await plant.apply_actions([light_action, water_action])
