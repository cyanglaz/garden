class_name Ring
extends Node2D

func _draw() -> void:
	draw_arc(Vector2.ZERO, 0.6, 0, 2*PI, 100, modulate, 0.1)
