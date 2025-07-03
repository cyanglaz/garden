class_name PlantDaisy
extends Plant

func _trigger_harvest_ability() -> void:
	Singletons.main_game.energy_tracker.value += 1
	harvest_ability_triggered.emit()
