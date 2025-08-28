class_name PlantRose
extends Plant

func _has_ability(ability_type:AbilityType) -> bool:
	return ability_type == AbilityType.HARVEST

func _trigger_ability(ability_type:AbilityType, main_game:MainGame) -> void:
	assert(ability_type == AbilityType.HARVEST)
	pass
