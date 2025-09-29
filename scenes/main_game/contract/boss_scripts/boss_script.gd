class_name BossScript
extends RefCounted

signal level_hook_complicated()

enum HookType {
	LEVEL_START,
	TURN_START,
}

@warning_ignore("unused_private_class_variable")
var boss_data:BossData: set = _set_boss_data, get = _get_boss_data
var _weak_boss_data:WeakRef = weakref(null)

func has_level_start_hook() -> bool:
	return _has_level_start_hook()

func has_turn_start_hook() -> bool:
	return _has_turn_start_hook()

func handle_turn_start_hook(main_game:MainGame) -> void:
	await _handle_turn_start_hook(main_game)

func handle_level_start_hook(main_game:MainGame) -> void:
	await _handle_level_start_hook(main_game)

#region for override

func _has_level_start_hook() -> bool:
	return false

func _has_turn_start_hook() -> bool:
	return false

func _handle_turn_start_hook(_main_game:MainGame) -> void:
	await Util.await_for_tiny_time()
	level_hook_complicated.emit()

func _handle_level_start_hook(_main_game:MainGame) -> void:
	await Util.await_for_tiny_time()
	level_hook_complicated.emit()

func _set_boss_data(value:BossData) -> void:
	_weak_boss_data = weakref(value)			

func _get_boss_data() -> BossData:
	return _weak_boss_data.get_ref()

#endregion
