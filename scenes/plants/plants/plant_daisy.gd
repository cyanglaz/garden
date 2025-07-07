class_name PlantDaisy
extends Plant

func _trigger_ability(ability_type:AbilityType, main_game:MainGame) -> void:
	if ability_type != AbilityType.HARVEST:
		return
	await Util.await_for_tiny_time()
	Singletons.main_game.energy_tracker.value += 1
	ability_triggered.emit(ability_type)
