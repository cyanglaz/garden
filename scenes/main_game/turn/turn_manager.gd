class_name TurnManager
extends RefCounted

var turn:int = 0
var _time_tracker:ResourcePoint: get = _get_time_tracker

var _weak_time_tracker:WeakRef

func _init(time_tracker:ResourcePoint) -> void:
	_weak_time_tracker = weakref(time_tracker)

func start_new(max_time:int) -> void:
	_time_tracker.setup(0, max_time)
	turn = 0

func next_turn() -> void:
	turn += 1
	_time_tracker.value = 0

func _get_time_tracker() -> ResourcePoint:
	return _weak_time_tracker.get_ref()
