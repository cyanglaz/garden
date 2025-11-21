class_name PlantAbility
extends Node2D

var ability_data:PlantAbilityData

func has_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> bool:
	return _has_ability_hook(ability_type, plant)

func trigger_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> void:
	await _trigger_ability_hook(ability_type, plant)

#region for override

func _has_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant) -> bool:
	return false

func _trigger_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant) -> void:
	await Util.await_for_tiny_time()

#endregion
