class_name GUIHPSegment
extends PanelContainer

@onready var texture_rect: TextureRect = %TextureRect

var is_empty:bool = false: set = _set_is_empty

func _set_is_empty(value:bool) -> void:
	is_empty = value
	if is_empty:
		(texture_rect.texture as AtlasTexture).region.position.x = 4
	else:
		(texture_rect.texture as AtlasTexture).region.position.x = 0
