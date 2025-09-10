class_name LevelScript
extends RefCounted

signal level_hook_complicated()

enum HookType {
	LEVEL_START,
	TURN_START,
}

@warning_ignore("unused_private_class_variable")
var level_data:LevelData: set = _set_level_data, get = _get_level_data
var _weak_level_data:WeakRef = weakref(null)

func has_level_start_hook() -> bool:
	return _has_level_start_hook()

func has_turn_start_hook() -> bool:
	return _has_turn_start_hook()

func handle_turn_start_hook(main_game:MainGame, icon:GUIEnemy) -> void:
	await _handle_turn_start_hook(main_game, icon)

func handle_level_start_hook(main_game:MainGame, icon:GUIEnemy) -> void:
	await _handle_level_start_hook(main_game, icon)

#region for override

func _has_level_start_hook() -> bool:
	return false

func _has_turn_start_hook() -> bool:
	return false

func _handle_turn_start_hook(_main_game:MainGame, _icon:GUIEnemy) -> void:
	await Util.await_for_tiny_time()
	level_hook_complicated.emit()

func _handle_level_start_hook(_main_game:MainGame, _icon:GUIEnemy) -> void:
	await Util.await_for_tiny_time()
	level_hook_complicated.emit()

func _set_level_data(value:LevelData) -> void:
	_weak_level_data = weakref(value)

func _get_level_data() -> LevelData:
	return _weak_level_data.get_ref()

#endregion
