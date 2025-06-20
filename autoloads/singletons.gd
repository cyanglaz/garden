extends Node

var game_main:GameMain: set = _set_game_main, get = _get_game_main

var _weak_game_main:WeakRef = weakref(null)

func _set_game_main(val:GameMain) -> void:
	_weak_game_main = weakref(val)

func _get_game_main() -> GameMain:
	return _weak_game_main.get_ref()