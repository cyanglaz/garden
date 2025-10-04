class_name PlantStateHarvest
extends PlantState

func enter() -> void:
	super.enter()
	plant.harvest_started.emit()
	await _handle_ability()
	_play_harvest_animation()
	plant.harvest_completed.emit()

func _play_harvest_animation() -> void:
	plant.field.show_harvest_popup()
	exit("")

func _handle_ability() -> void:
	# Must wait to make the operation async even if the plant does not have any ability hooks
	await Util.await_for_tiny_time()
	await plant.trigger_ability(Plant.AbilityType.HARVEST, Singletons.main_game)

func _get_animation_name() -> String:
	return "idle"
