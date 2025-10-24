class_name PlantAbility
extends Node2D

var ability_data:PlantAbilityData

func has_ability_hook(ability_type:Plant.AbilityType, combat_main:CombatMain, plant:Plant) -> bool:
	return _has_ability_hook(ability_type, combat_main, plant)

func trigger_ability_hook(ability_type:Plant.AbilityType, combat_main:CombatMain, plant:Plant) -> void:
	await _trigger_ability_hook(ability_type, combat_main, plant)

#region for override

func _has_ability_hook(_ability_type:Plant.AbilityType, _combat_main:CombatMain, _plant:Plant) -> bool:
	return false

func _trigger_ability_hook(_ability_type:Plant.AbilityType, _combat_main:CombatMain, _plant:Plant) -> void:
	await Util.await_for_tiny_time()

#endregion
