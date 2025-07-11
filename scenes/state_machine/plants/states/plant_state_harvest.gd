class_name PlantStateHarvest
extends PlantState

func enter() -> void:
	super.enter()
	plant.harvest_started.emit()
	await plant.field.status_manager.handle_harvest_gold_hooks(plant)
	await _handle_ability()
	await _gain_gold()
	_complete()

func _gain_gold() -> void:
	await plant.field.show_gold_popup()

func _handle_ability() -> void:
	await plant.trigger_ability(Plant.AbilityType.HARVEST, Singletons.main_game)

func _complete() -> void:
	plant.harvest_completed.emit()
	exit("")

func _get_animation_name() -> String:
	return "idle" + str("_", plant.stage)
