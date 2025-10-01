class_name PlantAbility
extends Node2D

func has_ability_hook(ability_type:Plant.AbilityType) -> bool:
	return _has_ability_hook(ability_type)

func trigger_ability_hook(ability_type:Plant.AbilityType, main_game:MainGame, plant:Plant) -> void:
	await _trigger_ability_hook(ability_type, main_game, plant)

#region for override

func _has_ability_hook(_ability_type:Plant.AbilityType) -> bool:
	return false

func _trigger_ability_hook(_ability_type:Plant.AbilityType, _main_game:MainGame, _plant:Plant) -> void:
	await Util.await_for_tiny_time()

#endregion
