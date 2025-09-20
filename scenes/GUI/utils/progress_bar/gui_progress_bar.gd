class_name GUIProgressBar
extends TextureProgressBar

signal animate_set_value_finished(value:int)

const animation_time := 0.2
var _animating_tween:Tween

func _ready() -> void:
	pivot_offset.x = size.x/2

func animated_set_value(target_value:float):
	if is_inside_tree():
		if _animating_tween && _animating_tween.is_running():
			_animating_tween.kill()
		_animating_tween = Util.create_scaled_tween(self)
		_animating_tween.tween_property(self, "value", target_value, animation_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		_animating_tween.play()
		await _animating_tween.finished
		animate_set_value_finished.emit(target_value)
