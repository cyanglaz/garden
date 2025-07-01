class_name GUIToolTimeIcon
extends HBoxContainer

@onready var _label: Label = %Label

var time:int: set = _set_time

func _ready() -> void:
	_label.text = str(time)

func _set_time(val:int) -> void:
	time = val
	if _label:
		_label.text = str(val)
