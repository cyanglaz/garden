class_name PowerScript
extends RefCounted

var power_data:PowerData
var _weak_power_data:WeakRef = weakref(null)

func _set_power_data(value:PowerData) -> void:
	_weak_power_data = weakref(value)

func _get_power_data() -> PowerData:
	return _weak_power_data.get_ref()
