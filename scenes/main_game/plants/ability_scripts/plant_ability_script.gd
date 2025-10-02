class_name PlantAbilityScript
extends RefCounted

var ability_data:PlantAbilityData: set = _set_ability_data, get = _get_ability_data
var _weak_ability_data:WeakRef = weakref(null)

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

func _set_ability_data(value:PlantAbilityData) -> void:
	_weak_ability_data = weakref(value)

func _get_ability_data() -> PlantAbilityData:
	return _weak_ability_data.get_ref()
