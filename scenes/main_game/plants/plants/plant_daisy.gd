class_name PlantDaisy
extends Plant

func _has_ability(ability_type:AbilityType) -> bool:
	return ability_type == AbilityType.HARVEST

func _trigger_ability(ability_type:AbilityType, _main_game:MainGame) -> void:
	assert(ability_type == AbilityType.HARVEST)
	await Singletons.main_game.draw_cards(data.data["card"] as int)
	ability_triggered.emit(ability_type)
