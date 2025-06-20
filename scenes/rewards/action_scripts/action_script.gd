class_name ActionScript
extends RefCounted

@warning_ignore("unused_signal")
signal action_completed()
@warning_ignore("unused_signal")
signal action_cancelled()

@warning_ignore("unused_private_class_variable")
var _action_data:ActionData:get = _get_action_data, set = _set_action_data

var _weak_data:WeakRef = weakref(null)

func _init(data:ActionData) -> void:
	_set_action_data(data)

func execute(_game_main:GameMain) -> void:
	await Util.create_scaled_timer(1.0).timeout
	assert(false, "must be overriden")

func _set_action_data(val:ActionData) -> void:
	_weak_data = weakref(val)

func _get_action_data() -> ActionData:
	return _weak_data.get_ref()
