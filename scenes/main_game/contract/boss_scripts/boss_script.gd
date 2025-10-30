class_name BossScript
extends RefCounted

enum HookType {
	LEVEL_START,
	TURN_START,
}

@warning_ignore("unused_private_class_variable")
var boss_data:BossData: set = _set_boss_data, get = _get_boss_data
var _weak_boss_data:WeakRef = weakref(null)

func has_hook(hook_type:HookType) -> bool:
	return _has_hook(hook_type)

func handle_hook(hook_type:HookType, combat_main:CombatMain) -> void:
	await _handle_hook(hook_type, combat_main)

#region for override

func _has_hook(_hook_type:HookType) -> bool:
	return false

func _handle_hook(_hook_type:HookType, _combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

#endregion

func _set_boss_data(value:BossData) -> void:
	_weak_boss_data = weakref(value)

func _get_boss_data() -> BossData:
	return _weak_boss_data.get_ref()