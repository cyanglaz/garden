class_name GUIProgressBar
extends TextureProgressBar

signal animate_set_value_finished(value:int)

const animation_time := 0.2

func _ready() -> void:
	pivot_offset.x = size.x/2

func animated_set_value(target_value:float):
	if is_inside_tree():
		var tween := Util.create_scaled_tween(self)
		tween.tween_property(self, "value", target_value, animation_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		tween.play()
		await tween.finished
		animate_set_value_finished.emit(target_value)
