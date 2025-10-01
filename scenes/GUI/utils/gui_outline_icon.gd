class_name GUIOutlineIcon
extends TextureRect

var has_outline:bool:set = _set_has_outline

func _set_has_outline(val:bool) -> void:
	has_outline = val
	if has_outline:
		material.set_shader_parameter("outline_size", 1)
	else:
		material.set_shader_parameter("outline_size", 0)
