class_name WeatherComponent
extends Node2D

@warning_ignore("unused_private_class_variable")
@onready var _animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

func _ready() -> void:
	_animated_sprite_2d.play("idle")
