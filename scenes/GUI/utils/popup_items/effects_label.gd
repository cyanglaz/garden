class_name EffectsLabel
extends Node2D

const ANIMATION_TIME := 1

@onready var label: Label = %Label
@onready var container: Node2D = %Container


#func _ready() -> void:
	#top_level = true

func set_value_with_default_animation(value:String, color:Color):
	_set_value_and_animate(value, 42, 1, 1, color)

func _set_value_and_animate(value:String, height:float, spread:float, final_scale:float, color:Color):
	var animation_time = ANIMATION_TIME
	label.text = value
	label.self_modulate = color
	var tween := create_tween()
	var end_position = Vector2(randf_range(-spread, spread), -height)
	tween.tween_property(container, "scale", Vector2(final_scale, final_scale), animation_time).from(Vector2(0.8, 0.8)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(container, "position", end_position, animation_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tween.play()
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	container.position = Vector2.ZERO
	# _tween = null
	queue_free()
