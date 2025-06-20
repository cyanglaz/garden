class_name FeedbackCamera2D
extends Camera2D
 
@onready var _screen_shake:ScreenShake  = %ScreenShake

func _ready():
	Events.request_camera_shake_effects.connect(_on_request_camera_shake_effects)
	Events.request_camera_default_shake_effects.connect(_on_request_camera_default_shake_effects)
	Events.request_zoom_in.connect(_on_request_zoom_in)
	Events.request_zoom_out.connect(_on_request_zoom_out)
	
func _on_request_camera_shake_effects(trauma:float, amplitude:Vector2, roll:float, decay:float, priority:int):
	_screen_shake.start(trauma, amplitude, roll, decay, priority)

func _on_request_camera_default_shake_effects(trauma:float):
	_screen_shake.start(trauma)

func _on_request_zoom_in(zoom_global_position:Vector2) -> void:
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(self, "zoom", Vector2(1.1, 1.1), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, "global_position", zoom_global_position, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	Events.camera_zoom_in_finished.emit()

func _on_request_zoom_out() -> void:
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(self, "zoom", Vector2.ONE, 0.2).set_custom_interpolator(func(x:float) -> float: return x)
	tween.parallel().tween_property(self, "global_position", Vector2.ZERO, 0.2).set_custom_interpolator(func(x:float) -> float: return x)
	await tween.finished
	Events.camera_zoom_out_finished.emit()
