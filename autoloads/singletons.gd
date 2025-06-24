extends Node

var main_game:MainGame:get = _get_main_game, set = _set_main_game

var _weak_main_game:WeakRef = weakref(null)

func _set_main_game(val:MainGame) -> void:
	_weak_main_game = weakref(val)

func _get_main_game() -> MainGame:
	return _weak_main_game.get_ref()
