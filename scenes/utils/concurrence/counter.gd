class_name Counter
extends RefCounted

signal completed

var _counter: int
var _total: int

func _init(p_total: int):
	_total = p_total
	_counter = 0

func submit():
	_counter = _counter + 1
	if _counter == _total:
		completed.emit()
