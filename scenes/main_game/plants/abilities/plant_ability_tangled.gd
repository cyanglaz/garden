class_name PlantAbilityTangled
extends PlantAbility

func _has_ability_hook(ability_type:Plant.AbilityType, _combat_main:CombatMain, _plant:Plant) -> bool:
	return ability_type == Plant.AbilityType.HARVEST

func _trigger_ability_hook(ability_type:Plant.AbilityType, combat_main:CombatMain, _plant:Plant) -> void:
	assert(ability_type == Plant.AbilityType.HARVEST)
	var combat_modifier:CombatModifier = CombatModifier.new()
	combat_modifier.modifier_type = CombatModifier.ModifierType.CARD_ENERGY_COST_MULTIPLICATIVE
	combat_modifier.modifier_timing = CombatModifier.ModifierTiming.TURN
	combat_modifier.modifier_value = 2
	combat_main.combat_modifier_manager.add_modifier(combat_modifier)
