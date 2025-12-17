class_name GUICurrentCombatButton
extends GUIBasicButton

@onready var _texture_rect: TextureRect = %TextureRect

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_texture_rect:
		return
	match button_state:
		ButtonState.NORMAL:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(0, 0)
		ButtonState.PRESSED:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(12, 0)
		ButtonState.HOVERED:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(24, 0)
		ButtonState.DISABLED:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(0, 12)
		ButtonState.SELECTED:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(24, 12)		
