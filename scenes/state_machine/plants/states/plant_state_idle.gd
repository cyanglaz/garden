class_name PlantStateIdle
extends PlantState

func _get_animation_name() -> String:
	if plant.is_grown():
		return "idle_1"
	else:
		return "idle_0"
