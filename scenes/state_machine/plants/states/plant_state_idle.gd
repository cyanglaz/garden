class_name PlantStateIdle
extends PlantState

func _get_animation_name() -> String:
	return "idle" + str("_", plant.stage)
