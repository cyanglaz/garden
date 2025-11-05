class_name PlantStateHarvest
extends PlantState

func enter() -> void:
	super.enter()
	var combat_main:CombatMain = params.get("combat_main")
	plant.harvest_started.emit()
	await _handle_ability(combat_main)
	_play_harvest_animation()
	plant.harvest_completed.emit()

func _play_harvest_animation() -> void:
	plant.show_harvest_popup()
	exit("")

func _handle_ability(combat_main:CombatMain) -> void:
	# Must wait to make the operation async even if the plant does not have any ability hooks
	await Util.await_for_tiny_time()
	await plant.trigger_ability(Plant.AbilityType.HARVEST, combat_main)

func _get_animation_name() -> String:
	return "idle"
