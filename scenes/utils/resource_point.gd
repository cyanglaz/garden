class_name ResourcePoint
extends RefCounted

signal value_update()
signal empty()
signal full()
signal max_value_update()
signal resetted()
signal estimate_value_updated(change:int)

var is_empty:bool : get = _get_is_empty
var is_full:bool : get = _get_is_full

var value:int: set = _set_value
var max_value:int: set = _set_max_value
var estimate_value:int
var capped:bool = true
var positive_value:bool = true

func get_duplicate() -> ResourcePoint:
	var dup:ResourcePoint = ResourcePoint.new()
	dup.setup(value, max_value)
	dup.estimate_value = estimate_value
	return dup

func setup(v:int, mv:int) -> void:
	max_value = mv
	value = v
	estimate_value = value

func reset():
	value = max_value
	resetted.emit()
	
func spend(amount:int) -> void:
	if amount > value:
		amount = value
	value -= amount
	if value <= 0:
		_value_empty()

func update_estimate(change:int) -> void:
	estimate_value += change
	estimate_value_updated.emit(change)

func reset_estimate() -> void:
	estimate_value = value
	estimate_value_updated.emit(value - estimate_value)

func restore(amount:int):
	var target_value = value + amount
	value = min(target_value, max_value)
	if value == max_value:
		full.emit()
		
func _get_is_empty() -> bool:
	return value <= 0

func _set_value(val:int):
	if capped && val > max_value:
		value = max_value
	elif positive_value && val < 0:
		value = 0
	else:
		value = val
	value_update.emit()

func _set_max_value(val:int):
	var diff := val - max_value
	max_value = val
	max_value_update.emit()
	value += diff

func _value_empty():
	empty.emit()

func _get_is_full() -> bool:
	print("value: ", value, " max_value: ", max_value)
	return value >= max_value
