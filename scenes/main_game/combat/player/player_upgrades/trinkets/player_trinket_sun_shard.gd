class_name PlayerTrinketSunShard
extends PlayerTrinket

func _has_end_turn_hook(combat_main:CombatMain) -> bool:
	var current_index:int = combat_main.player.current_field_index
	return current_index == 0 || current_index == combat_main.player.max_plants_index

func _handle_end_turn_hook(combat_main:CombatMain) -> void:
	var current_index:int = combat_main.player.current_field_index
	assert(current_index == 0 || current_index == combat_main.player.max_plants_index, "Current index is not 0 or max plants index")
	var current_plant:Plant = combat_main.plant_field_container.get_plant(current_index)
	var action_data:ActionData = ActionData.new()
	action_data.type = ActionData.ActionType.LIGHT
	action_data.operator_type = ActionData.OperatorType.INCREASE
	action_data.value = data.data["light"] as int
	_send_hook_animation_signals()
	await current_plant.apply_actions([action_data], combat_main)
