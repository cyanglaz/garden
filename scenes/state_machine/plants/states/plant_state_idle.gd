class_name PlantStateIdle
extends PlantState

func enter() -> void:
	super.enter()
	if !plant.stage_updated.is_connected(_on_stage_updated):
		plant.stage_updated.connect(_on_stage_updated)

func exit(next_state:String, next_params:Dictionary = {}) -> void:
	plant.stage_updated.disconnect(_on_stage_updated)
	super.exit(next_state, next_params)

func _get_animation_name() -> String:
	return "idle" + str("_", plant.stage)

func _on_stage_updated() -> void:
	plant.plant_sprite.play("idle" + str("_", plant.stage))
