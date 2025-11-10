class_name WeatherComponentSun
extends WeatherComponent

const IN_ANIMATION_TIME := 0.4
const OUT_ANIMATION_TIME := 0.4
const BOUNCE_HEIGHT := 4.0
const BOUNCE_TIME := 0.1

var _original_position_y:float

func _ready() -> void:
	super._ready()
	_original_position_y = global_position.y

func _animate_in() -> void:
	var ready_position_y := 0.0
	var tween:Tween = Util.create_scaled_tween(self)
	global_position.y = ready_position_y
	tween.tween_property(self, "global_position:y", _original_position_y - BOUNCE_HEIGHT, IN_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position:y", _original_position_y + BOUNCE_HEIGHT + 1.0, BOUNCE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position:y", _original_position_y, BOUNCE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func _animate_out() -> void:
	var tween:Tween = Util.create_scaled_tween(self)
	var out_position_y := -get_viewport_rect().size.y/2.0
	tween.tween_property(self, "global_position:y", out_position_y, OUT_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
