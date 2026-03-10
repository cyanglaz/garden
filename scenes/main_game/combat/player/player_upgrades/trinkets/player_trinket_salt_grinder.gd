class_name PlayerTrinketSaltGrinder
extends PlayerTrinket

func _has_start_turn_hook(_combat_main:CombatMain) -> bool:
	return true

func _handle_start_turn_hook(combat_main:CombatMain) -> void:
	var current_plant:Plant = combat_main.plant_field_container.get_plant(combat_main.player.current_field_index)
	var action_data_pest:ActionData = ActionData.new()
	action_data_pest	.type = ActionData.ActionType.PEST
	action_data_pest.operator_type = ActionData.OperatorType.DECREASE
	action_data_pest.value = data.data["pest"] as int
	var action_data_fungus:ActionData = ActionData.new()
	action_data_fungus.type = ActionData.ActionType.FUNGUS
	action_data_fungus.operator_type = ActionData.OperatorType.DECREASE
	action_data_fungus.value = data.data["fungus"] as int
	await current_plant.apply_actions([action_data_pest, action_data_fungus])
