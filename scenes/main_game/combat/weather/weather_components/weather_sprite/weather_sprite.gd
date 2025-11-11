class_name WeatherSprite
extends Node2D

const BOUNCE_OFFSET := 2.0
const TRANSITION_ANIMATION_TIME := 0.4
const BOUNCE_HEIGHT := 4.0
const BOUNCE_TIME := 0.1

signal animated_in_finished()
signal animated_out_finished()

enum TransitionType {
	NONE,
	VERTICAL,
	HORIZONTAL,
}

@export var transition_type: TransitionType = TransitionType.NONE

@warning_ignore("unused_private_class_variable")
@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

var _original_position:Vector2

func _ready() -> void:
	if _animated_sprite_2d.sprite_frames.get_animation_names().has("idle"):
		_animated_sprite_2d.play("idle")
	_animated_sprite_2d.hide()
	_original_position = global_position

func animate_in() -> void:
	_animated_sprite_2d.show()
	await _animate_in()
	animated_in_finished.emit()

func animate_out() -> void:
	await _animate_out()
	_animated_sprite_2d.hide()
	animated_out_finished.emit()

#region for override
func _animate_in() -> void:
	match transition_type:
		TransitionType.VERTICAL:
			await _animate_in_vertical()
		TransitionType.HORIZONTAL:
			await _animate_in_horizontal()
		TransitionType.NONE:
			assert(false, "Transition type is not set")

func _animate_out() -> void:
	match transition_type:
		TransitionType.VERTICAL:
			await _animate_out_vertical()
		TransitionType.HORIZONTAL:
			await _animate_out_horizontal()
		TransitionType.NONE:
			assert(false, "Transition type is not set")
#endregion

#region helper functions

func _animate_in_vertical() -> void:
	var hide_position_y := _original_position.y + get_viewport_rect().size.y/2.0
	var tween:Tween = Util.create_scaled_tween(self)
	global_position.y = hide_position_y
	tween.tween_property(self, "global_position:y", _original_position.y - BOUNCE_OFFSET, TRANSITION_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position:y", _original_position.y + BOUNCE_OFFSET - 1.0, BOUNCE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position:y", _original_position.y, BOUNCE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func _animate_out_vertical() -> void:
	var tween:Tween = Util.create_scaled_tween(self)
	var out_position_y := _original_position.y - get_viewport_rect().size.y/2.0
	tween.tween_property(self, "global_position:y", out_position_y, TRANSITION_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished

func _animate_in_horizontal() -> void:
	var hide_position_x := _original_position.x + get_viewport_rect().size.x
	var tween:Tween = Util.create_scaled_tween(self)
	global_position.x = hide_position_x
	tween.tween_property(self, "global_position:x", _original_position.x - BOUNCE_OFFSET, TRANSITION_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position:x", _original_position.x + BOUNCE_OFFSET - 1.0, BOUNCE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position:x", _original_position.x, BOUNCE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished

func _animate_out_horizontal() -> void:
	var tween:Tween = Util.create_scaled_tween(self)
	var out_position_x := _original_position.x - get_viewport_rect().size.x
	tween.tween_property(self, "global_position:x", out_position_x, TRANSITION_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
#region
