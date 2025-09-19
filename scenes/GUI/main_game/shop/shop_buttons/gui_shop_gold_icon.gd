class_name GUIShopGoldIcon
extends PanelContainer

@onready var texture_rect: TextureRect = %TextureRect

var has_outline:bool:set = _set_has_outline

func _set_has_outline(val:bool) -> void:
	has_outline = val
	if has_outline:
		texture_rect.material.set_shader_parameter("outline_size", 1)
	else:
		texture_rect.material.set_shader_parameter("outline_size", 0)
