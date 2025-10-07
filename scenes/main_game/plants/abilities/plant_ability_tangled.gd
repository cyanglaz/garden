class_name PlantAbilityTangled
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType, _main_game:MainGame, _plant:Plant) -> bool:
	return ability_type == Plant.AbilityType.HARVEST

func _trigger_ability_hook(ability_type:Plant.AbilityType, main_game:MainGame, _plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.HARVEST)
	var game_modifier:GameModifier = GameModifier.new()
	game_modifier.modifier_type = GameModifier.ModifierType.CARD_ENERGY_COST_MULTIPLICATIVE
	game_modifier.modifier_timing = GameModifier.ModifierTiming.TURN
	game_modifier.modifier_value = 2
	main_game.game_modifier_manager.add_modifier(game_modifier)
