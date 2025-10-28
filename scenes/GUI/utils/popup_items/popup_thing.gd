class_name PopupThing
extends PanelContainer

const BUMP_UP_TIME := 0.2
const BUMP_UP_DISTANCE := 2.0
const BUMP_UP_SPREAD := 3.0

var _position_tween:Tween
var end_position:Vector2

func _ready() -> void:
	top_level = true

func animate_show(height:float, spread:float, time:float):
	pivot_offset = size/2
	var from_global_position = global_position - size/2
	global_position = from_global_position
	var tween = Util.create_scaled_tween(self)
	var end_x_position := randf_range(-spread, spread)
	end_position = global_position + Vector2(end_x_position, -height)
	modulate.a = 0.0
	_position_tween = Util.create_scaled_tween(self)
	_position_tween.parallel().tween_property(self, "global_position", end_position, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.parallel().tween_property(self, "scale", Vector2(final_scale, final_scale), time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, "modulate:a", 1.0, time/2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	await _position_tween.finished
	_position_tween = null

func animate_destroy(time:float) -> void:
	var tween = Util.create_scaled_tween(self)
	tween.tween_property(self, "modulate:a", 0.0, time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	await tween.finished
	queue_free()

func bump_up(height:float) -> void:
	end_position += Vector2(randf_range(-BUMP_UP_SPREAD, BUMP_UP_SPREAD), -height)
	if _position_tween && _position_tween.is_running():
		_position_tween.kill()
	_position_tween = Util.create_scaled_tween(self)
	_position_tween.parallel().tween_property(self, "global_position", end_position, BUMP_UP_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
	_position_tween.play()
	await _position_tween.finished
	_position_tween = null
