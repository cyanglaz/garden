class_name PlayerTrinketFermentationFlask
extends PlayerTrinket

func _has_start_turn_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_start_turn_hook(_combat_main: CombatMain) -> void:
	data.stack = 0

func _has_discard_hook(_combat_main: CombatMain, _tool_datas: Array) -> bool:
	return true

func _handle_discard_hook(combat_main: CombatMain, tool_datas: Array) -> void:
	var trinket_data := data as TrinketData
	trinket_data.stack += tool_datas.size()
	var new_stack := trinket_data.stack
	var loop_count := 0
	while new_stack >= int(data.data[&"discard_count"]):
		new_stack -= int(data.data[&"discard_count"])
		loop_count += 1
	if loop_count > 0:
		var plant := combat_main.get_current_player_plant()
		var light_action := ActionData.new()
		light_action.type = ActionData.ActionType.LIGHT
		light_action.operator_type = ActionData.OperatorType.INCREASE
		light_action.value = int(data.data[&"light"]) * loop_count
		var water_action := ActionData.new()
		water_action.type = ActionData.ActionType.WATER
		water_action.operator_type = ActionData.OperatorType.INCREASE
		water_action.value = int(data.data[&"water"]) * loop_count
		await plant.apply_actions([light_action, water_action])
		trinket_data.stack = new_stack
