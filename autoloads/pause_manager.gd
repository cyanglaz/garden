extends Node

var _pause_count:int = 0

func try_pause() -> void:
	if _pause_count == 0:
		get_tree().paused = true
	assert(_pause_count >= 0)
	_pause_count += 1

func try_unpause() -> void:
	_pause_count -= 1
	if _pause_count <= 0:
		get_tree().paused = false
