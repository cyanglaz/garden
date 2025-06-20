@tool
class_name GUILabeledSlider
extends HBoxContainer

signal value_changed(value: int)

@export var localized_title:String: set = _set_localized_title
@export var value_range:Vector2i

@onready var _label := %Title
@onready var _slider := %GUIBasicSlider

func _ready() -> void:
	_slider.value_changed.connect(_on_value_changed)
	_slider.min_value = value_range.x
	_slider.max_value = value_range.y
	_slider.step = 1
	_set_localized_title(localized_title)

func set_slider_value_no_signal(val:int) -> void:
	_slider.set_value_no_signal(val)

func _on_value_changed(value: float) -> void:
	value_changed.emit(value as int)

func _set_localized_title(val:String) -> void:
	localized_title = val
	if _label:
		_label.text = tr(localized_title)
