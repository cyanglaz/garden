class_name PlayerStateMachine
extends FiniteStateMachine

var _player: Player:get = _get_player

func _ready() -> void:
	for state in _states.get_children():
		state.player = _player

func _get_player() -> Player:
	return get_parent() as Player
