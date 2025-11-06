class_name Water
extends Node2D

@onready var parallax_2d: Parallax2D = %Parallax2D
@onready var water: TileMapLayer = %Water

#func _process(delta: float) -> void:
	#parallax_2d.scroll_offset.x -= 5 * delta

func _ready() -> void:
	var repeat_x := water.rendering_quadrant_size * 3
	parallax_2d.repeat_size = Vector2(repeat_x, 0)
	parallax_2d.autoscroll = Vector2.LEFT * 2
	parallax_2d.ignore_camera_scroll = true
