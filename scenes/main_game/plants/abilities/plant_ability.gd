class_name PlantAbility
extends Node2D

var ability_data:PlantAbilityData
var stack:int = 0
var current_cooldown:int = 0

func has_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> bool:
	if current_cooldown > 0:
		if ability_type == Plant.AbilityType.END_TURN:
			current_cooldown -= 1
		return false
	return _has_ability_hook(ability_type, plant)

func trigger_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> void:
	await _trigger_ability_hook(ability_type, plant)
	current_cooldown = ability_data.cooldown

#region for override

func _has_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant) -> bool:
	return false

func _trigger_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant) -> void:
	await Util.await_for_tiny_time()

#endregion
