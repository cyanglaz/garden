class_name FieldStatusScript
extends RefCounted

@warning_ignore("unused_signal")
signal hook_complicated()

enum HookResultType {
	PASS, # caller need to await for hook_complicated signal, then continue doing what they want to do
	ABORT, # caller need to await for hook_complicated signal, then abort the action
}

func has_harvest_ability_hook() -> bool:
	return _has_harvest_ability_hook()

func handle_harvest_ability_hook(plant:Plant) -> HookResultType:
	return _handle_harvest_ability_hook(plant)

func has_end_day_hook() -> bool:
	return _has_end_day_hook()

func handle_end_day_hook(field:Field) -> HookResultType:
	return _handle_end_day_hook(field)

#region for override

func _has_harvest_ability_hook() -> bool:
	return false

func _handle_harvest_ability_hook(_plant:Plant) -> HookResultType:
	return HookResultType.PASS

func _has_end_day_hook() -> bool:
	return false

func _handle_end_day_hook(_field:Field) -> HookResultType:
	return HookResultType.PASS

#endregion
