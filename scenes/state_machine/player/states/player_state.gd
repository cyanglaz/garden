class_name PlayerState
extends State

var player: Player:get = _get_player, set = _set_player
var _weak_player: WeakRef = weakref(null)

func enter() -> void:
	super.enter()
	player.player_sprite.play(_get_animation_name())

func _set_player(value: Player) -> void:
	_weak_player = weakref(value)

func _get_player() -> Player:
	return _weak_player.get_ref()

func _get_animation_name() -> String:
	return ""
