class_name PlantStateBloom
extends PlantState

func enter() -> void:
	plant.bloom_particle.restart()
	super.enter()
	plant.bloom_started.emit()
	_play_bloom_animation()
	var combat_main:CombatMain = params["combat_main"]
	await plant.trigger_ability(Plant.AbilityType.BLOOM, combat_main)
	plant.field_status_container.clear_all_statuses()
	plant.plant_ability_container.clear_all_abilities()
	plant.bloom_completed.emit()

func _play_bloom_animation() -> void:
	plant.show_bloom_popup()

func _get_animation_name() -> String:
	return "bloom"
