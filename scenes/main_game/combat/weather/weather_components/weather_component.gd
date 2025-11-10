class_name WeatherComponent
extends Node2D

signal animated_in_finished()
signal animated_out_finished()

@warning_ignore("unused_private_class_variable")
@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

func _ready() -> void:
	_animated_sprite_2d.play("idle")
	_animated_sprite_2d.hide()

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
	await Util.await_for_tiny_time()

func _animate_out() -> void:
	await Util.await_for_tiny_time()
#endregion
