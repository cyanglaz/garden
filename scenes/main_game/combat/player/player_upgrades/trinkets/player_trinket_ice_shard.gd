class_name PlayerTrinketIceShard
extends PlayerTrinket

func _has_end_turn_hook(_combat_main:CombatMain) -> bool:
	return true

func _handle_end_turn_hook(combat_main:CombatMain) -> void:
	var current_plant:Plant = combat_main.plant_field_container.get_plant(combat_main.player.current_field_index)
	var action_data:ActionData = ActionData.new()
	action_data.type = ActionData.ActionType.WATER
	action_data.operator_type = ActionData.OperatorType.INCREASE
	action_data.value = data.data["water"] as int
	_send_hook_animation_signals()
	await current_plant.apply_actions([action_data], combat_main)
