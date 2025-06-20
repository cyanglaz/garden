class_name GradientPointLight2D
extends PointLight2D

@export var light_range:float = 0 : set = set_light_range

@onready var _gradient_texture = texture as GradientTexture2D

func _ready() -> void:
	_update_range(light_range)
	
func set_light_range(val:float):
	if val == light_range:
		return
	light_range = val
	if _gradient_texture != null:
		_update_range(light_range)

func _update_range(val:float):
	if val > 0:
		_gradient_texture.width = val * 2
		_gradient_texture.height = val * 2
