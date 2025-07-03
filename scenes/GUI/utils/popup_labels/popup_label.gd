class_name PopupLabel
extends Label

func _ready() -> void:
	top_level = true

func animate_show(value:String, height:float, spread:float, time:float, color:Color):
	text = value
	self_modulate = color
	pivot_offset = size/2
	var from_global_position = global_position - size/2
	global_position = from_global_position
	var tween = Util.create_scaled_tween(self)
	var end_x_position := randf_range(-spread, spread)
	var end_position = global_position + Vector2(end_x_position, -height)
	modulate.a = 0.0
	tween.parallel().tween_property(self, "global_position", end_position, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.parallel().tween_property(self, "scale", Vector2(final_scale, final_scale), time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, "modulate:a", 1.0, time/2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	await tween.finished

func animate_destroy(time:float) -> void:
	var tween = Util.create_scaled_tween(self)
	tween.tween_property(self, "modulate:a", 0.0, time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	await tween.finished
	queue_free()

func animate_show_and_destroy(value:String, height:float, spread:float, show_time:float, destroy_time:float, color:Color) -> void:
	await animate_show(value, height, spread, show_time, color)
	animate_destroy(destroy_time)
