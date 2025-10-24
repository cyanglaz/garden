@abstract
class_name FieldStatusScript
extends RefCounted

@warning_ignore("unused_private_class_variable")
var status_data:FieldStatusData: get = _get_status_data, set = _set_status_data
var _weak_data:WeakRef = weakref(self)

@warning_ignore("unused_signal")
signal hook_complicated()

func has_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> bool:
	return _has_ability_hook(ability_type, plant)

func handle_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> void:
	await _handle_ability_hook(ability_type, plant)

func has_harvest_hook(plant:Plant) -> bool:
	return _has_harvest_hook(plant)

func handle_harvest_hook(plant:Plant) -> void:
	await _handle_harvest_hook(plant)

func has_add_water_hook(combat_main:CombatMain, plant:Plant) -> bool:
	return _has_add_water_hook(combat_main, plant)

func handle_add_water_hook(combat_main:CombatMain, plant:Plant) -> void:
	await _handle_add_water_hook(combat_main, plant)

func has_tool_application_hook(plant:Plant) -> bool:
	return _has_tool_application_hook(plant)

func handle_tool_application_hook(plant:Plant) -> void:
	await _handle_tool_application_hook(plant)

func has_tool_discard_hook(count:int, plant:Plant) -> bool:
	return _has_tool_discard_hook(count, plant)

func handle_tool_discard_hook(plant:Plant, count:int) -> void:
	await _handle_tool_discard_hook(plant, count)

func has_end_day_hook(plant:Plant) -> bool:
	return _has_end_day_hook(plant)

func handle_end_day_hook(combat_main:CombatMain, plant:Plant) -> void:
	await _handle_end_day_hook(combat_main, plant)

#region for override

func _has_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant) -> bool:
	return false

func _handle_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant) -> void:
	await Util.await_for_tiny_time()

func _has_harvest_hook(_plant:Plant) -> bool:
	return false

func _handle_harvest_hook(_plant:Plant) -> void:
	await Util.await_for_tiny_time()

func _has_tool_application_hook(_plant:Plant) -> bool:
	return false

func _handle_tool_application_hook(_plant:Plant) -> void:
	await Util.await_for_tiny_time()
	
func _has_tool_discard_hook(_count:int, _plant:Plant) -> bool:
	return false

func _has_add_water_hook(_combat_main:CombatMain, _plant:Plant) -> bool:
	return false

func _handle_add_water_hook(_combat_main:CombatMain, _plant:Plant) -> void:
	await Util.await_for_tiny_time()

func _has_end_day_hook(_plant:Plant) -> bool:
	return false

func _handle_end_day_hook(_combat_main:CombatMain, _plant:Plant) -> void:
	await Util.await_for_tiny_time()

func _handle_tool_discard_hook(_plant:Plant, _count:int) -> void:
	await Util.await_for_tiny_time()

#endregion

func _get_status_data() -> FieldStatusData:
	return _weak_data.get_ref()

func _set_status_data(value:FieldStatusData) -> void:
	_weak_data = weakref(value)
