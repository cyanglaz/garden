class_name GUIIcon
extends TextureRect

var has_outline:bool:set = _set_has_outline
var is_highlighted:bool = false:set = _set_is_highlighted

func _set_has_outline(val:bool) -> void:
	has_outline = val
	if has_outline:
		material.set_shader_parameter("outline_size", 1)
	else:
		material.set_shader_parameter("outline_size", 0)

func _set_is_highlighted(val:bool) -> void:
	is_highlighted = val
	if is_highlighted:
		(material as ShaderMaterial).set_shader_parameter("blend_strength", 0.2)
	else:
		(material as ShaderMaterial).set_shader_parameter("blend_strength", 0.0)
