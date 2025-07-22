class_name PlantStateHarvest
extends PlantState

func enter() -> void:
	super.enter()
	plant.harvest_started.emit()
	await plant.field.status_manager.handle_harvest_gold_hooks(plant)
	await _handle_ability()
	_gain_gold()

func _gain_gold() -> void:
	await plant.field.show_gold_popup()
	plant.harvest_gold_update_requested.emit(plant.data.gold)
	exit("")

func _handle_ability() -> void:
	await plant.trigger_ability(Plant.AbilityType.HARVEST, Singletons.main_game)

func _get_animation_name() -> String:
	return "idle" + str("_", plant.stage)

