class_name Tavern
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

var highlighted := false: set = _set_highlighted

func _set_highlighted(val:bool) -> void:
	highlighted = val
	if highlighted:
		animated_sprite_2d.material.set_shader_parameter("outline_size", 1)
	else:
		animated_sprite_2d.material.set_shader_parameter("outline_size", 0)
