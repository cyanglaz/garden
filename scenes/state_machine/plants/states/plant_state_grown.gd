class_name PlantStateBloom
extends PlantState

func enter() -> void:
	super.enter()
	var combat_main:CombatMain = params.get("combat_main")
	plant.bloom_started.emit()
	plant.status_manager.clear_all_statuses()
	await _handle_ability(combat_main)
	_play_bloom_animation()
	plant.bloom_completed.emit()

func _play_bloom_animation() -> void:
	plant.show_bloom_popup()

func _handle_ability(combat_main:CombatMain) -> void:
	# Must wait to make the operation async even if the plant does not have any ability hooks
	await Util.await_for_tiny_time()
	await plant.trigger_ability(Plant.AbilityType.BLOOM, combat_main)

func _get_animation_name() -> String:
	return "bloom"
