class_name PlantStatePreview
extends PlantState

func _get_animation_name() -> String:
	return "idle" + str("_", 1)
