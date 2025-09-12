class_name GUICloseButton
extends GUIBasicButton

const CLICK_SOUND := preload("res://resources/sounds/GUI/close_button_click.wav")
const HOVER_SOUND := preload("res://resources/sounds/GUI/close_button_hover.wav")

@onready var _texture_rect: TextureRect = %TextureRect

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_texture_rect:
		return
	match button_state:
		ButtonState.NORMAL:
			_texture_rect.texture.region.position = Vector2(0, 0)
		ButtonState.PRESSED:
			_texture_rect.texture.region.position = Vector2(9, 0)
		ButtonState.HOVERED:
			_texture_rect.texture.region.position = Vector2(18, 0)
		ButtonState.DISABLED:
			_texture_rect.texture.region.position = Vector2(0, 9)
		ButtonState.SELECTED:
			_texture_rect.texture.region.position = Vector2(9, 9)		

func _get_hover_sound() -> AudioStream:
	return HOVER_SOUND

func _get_click_sound() -> AudioStream:
	return CLICK_SOUND
