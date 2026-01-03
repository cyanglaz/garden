class_name AttackIndicator
extends Node2D

@onready var line_2d: Line2D = %Line2D

func set_from_to(global_position_from:Vector2, global_position_to:Vector2) -> void:
	line_2d.clear_points()
	line_2d.add_point(to_local(global_position_from))
	line_2d.add_point(to_local(global_position_to))
