class_name FieldStatusFungus
extends FieldStatus

const FUNGUS_SCENE := preload("res://scenes/main_game/combat/fields/status/status_components/fungus.tscn")

var _number_of_fungi:int = 0

func _update_for_plant(plant:Plant) -> void:
	var diff_number_of_fungi := stack - _number_of_fungi
	if diff_number_of_fungi > 0:
		for i in diff_number_of_fungi:
			var fungus:Fungus = FUNGUS_SCENE.instantiate()
			add_child(fungus)
			fungus.position = _get_random_fungus_position(plant)
	elif diff_number_of_fungi < 0:
		for i in range(diff_number_of_fungi):
			var fungus:Fungus = get_children().back()
			fungus.queue_free()
	_number_of_fungi = stack

func _has_end_turn_hook(plant:Plant) -> bool:
	return plant != null

func _handle_end_turn_hook(_combat_main:CombatMain, plant:Plant) -> void:
	var reduce_water_action:ActionData = ActionData.new()
	reduce_water_action.type = ActionData.ActionType.WATER
	reduce_water_action.operator_type = ActionData.OperatorType.DECREASE
	reduce_water_action.value = (status_data.data["value"] as int) * stack
	await plant.apply_actions([reduce_water_action])

func _get_random_fungus_position(plant:Plant) -> Vector2:
	var field_width:float = plant.field.land_width
	var spawn_range:float = field_width - 4.0
	return Vector2(randf_range(-spawn_range/2.0, spawn_range/2.0), 0)
