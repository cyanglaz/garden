class_name PowerScript
extends RefCounted

var power_data:PowerData: get = get_power_data, set = set_power_data
var _weak_power_data:WeakRef = weakref(null)

@warning_ignore("unused_signal")
signal power_deployed()
@warning_ignore("unused_signal")
signal power_cancelled()

func activate(_game_main:GameMain) -> void:
	pass

func deactivate() -> void:
	pass

func get_power_data() -> PowerData:
	return _weak_power_data.get_ref()

func set_power_data(new_power_data:PowerData) -> void:
	_weak_power_data = weakref(new_power_data)
