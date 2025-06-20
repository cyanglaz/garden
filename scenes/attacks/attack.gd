class_name Attack
extends RefCounted

var basic_damage:int
var additional_damage:int = 0
var damage:int: get = _get_damage, set = _set_damage
var target:Character:get = _get_target

var _weak_target:WeakRef = weakref(null)

func _init(t:Character, basic_dmg:int) -> void:
	basic_damage = basic_dmg
	_weak_target = weakref(t)

func _get_damage() -> int:
	return maxi(basic_damage + additional_damage, 0)

func _set_damage(_val:int) -> void:
	assert(false, "damage is read-only")

func _get_target() -> Character:
	return _weak_target.get_ref()
