class_name PlantStateIdle
extends PlantState

func _get_animation_name() -> String:
	return "idle" 

func _on_stage_updated() -> void:
	plant.plant_sprite.play("idle")
