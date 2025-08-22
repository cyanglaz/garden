class_name PlantStateHarvest
extends PlantState

func enter() -> void:
	super.enter()
	plant.harvest_started.emit()
	await plant.field.status_manager.handle_harvest_gold_hooks(plant)
	await _handle_ability()
	_gain_points()
	plant.harvest_completed.emit()

func _gain_points() -> void:
	await plant.field.show_point_popup()
	plant.harvest_point_update_requested.emit(plant.data.points)
	exit("")

func _handle_ability() -> void:
	await plant.trigger_ability(Plant.AbilityType.HARVEST, Singletons.main_game)

func _get_animation_name() -> String:
	return "idle" + str("_", plant.stage)
