class_name WeatherComponentSun
extends WeatherComponent

const IN_ANIMATION_TIME := 0.3
const OUT_ANIMATION_TIME := 0.3
const OFFSET_Y := 50

var _original_position_y:float

func _ready() -> void:
	super._ready()
	_original_position_y = global_position.y

func _animate_in() -> void:
	var tween:Tween = Util.create_scaled_tween(self)
	global_position.y = _original_position_y + OFFSET_Y
	tween.tween_property(self, "global_position:y", _original_position_y, IN_ANIMATION_TIME).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	await tween.finished

func _animate_out() -> void:
	var tween:Tween = Util.create_scaled_tween(self)
	tween.tween_property(self, "global_position:y", _original_position_y - OFFSET_Y, OUT_ANIMATION_TIME).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	await tween.finished
