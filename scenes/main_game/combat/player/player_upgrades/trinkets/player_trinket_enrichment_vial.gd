class_name PlayerTrinketEnrichmentVial
extends PlayerTrinket

var _last_triggered_turn := -1

func _has_start_turn_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_start_turn_hook(_combat_main: CombatMain) -> void:
	data.state = TrinketData.TrinketState.ACTIVE

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
	_send_hook_animation_signals()
	await plant.apply_actions([light_action, water_action], combat_main)
	data.state = TrinketData.TrinketState.NORMAL

func _has_combat_end_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_combat_end_hook(_combat_main: CombatMain) -> void:
	data.state = TrinketData.TrinketState.NORMAL
