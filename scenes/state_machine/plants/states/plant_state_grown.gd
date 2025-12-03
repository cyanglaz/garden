class_name PlantStateBloom
extends PlantState

func enter() -> void:
	super.enter()
	plant.bloom_started.emit()
	plant.status_manager.clear_all_statuses()
	plant.curse_particle.stop()
	plant.bloom_particle.restart()
	_play_bloom_animation()
	plant.bloom_completed.emit()

func _play_bloom_animation() -> void:
	plant.show_bloom_popup()

func _get_animation_name() -> String:
	return "bloom"
