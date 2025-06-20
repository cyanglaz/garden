@tool
class_name GUIRPBar
extends Control

signal value_update_finished()

@export var progress_color:Color
@export var under_color:Color

@onready var _rp_bar: GUIProgressBar = %RPBar
@onready var _label: Label = %Label

func _ready() -> void:
	_rp_bar.tint_progress = progress_color
	_rp_bar.tint_under = under_color

func bind_with_rp(rp:ResourcePoint) -> void:
	_label.text = str(_get_value_text(rp), "/", rp.max_value)
	_rp_bar.max_value = rp.max_value
	_rp_bar.value = rp.value

func get_reference_position() -> Vector2:
	return global_position + _rp_bar.position + _rp_bar.size/2

func animate_value_update(rp:ResourcePoint, time:float) -> void:
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(_rp_bar, "value", rp.value, time)
	tween.tween_callback(func():
		_label.text = str(_get_value_text(rp), "/", rp.max_value)
	)
	tween.tween_callback(func():
		value_update_finished.emit()
	)
	await tween.finished
	# Add a small delay for player.
	await Util.create_scaled_timer(0.3).timeout
	
func _get_value_text(rp:ResourcePoint) -> String:
	var value_text := str(rp.value)
	if rp.value < 0:
		value_text = "0"
	return value_text
