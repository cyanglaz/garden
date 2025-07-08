class_name FieldStatusScript
extends RefCounted

@warning_ignore("unused_signal")
signal hook_complicated()

enum HookResultType {
	PASS, # caller need to await for hook_complicated signal, then continue doing what they want to do
	ABORT, # caller need to await for hook_complicated signal, then abort the action
}

func has_harvest_gold_hook() -> bool:
	return _has_harvest_gold_hook()

func handle_harvest_gold_hook(plant:Plant) -> void:
	_handle_harvest_gold_hook(plant)

func has_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> bool:
	return _has_ability_hook(ability_type, plant)

func handle_ability_hook(ability_type:Plant.AbilityType, plant:Plant) -> HookResultType:
	return _handle_ability_hook(ability_type, plant)

#region for override

func _has_harvest_gold_hook() -> bool:
	return false

func _handle_harvest_gold_hook(_plant:Plant) -> void:
	pass

func _has_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant) -> bool:
	return false

func _handle_ability_hook(_ability_type:Plant.AbilityType, _plant:Plant) -> HookResultType:
	return HookResultType.PASS

#endregion
