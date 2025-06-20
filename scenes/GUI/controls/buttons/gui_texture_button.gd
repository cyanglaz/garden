@tool
class_name GUITextureButton
extends GUIBasicButton

@export var texture:AtlasTexture
@export var texture_size:Vector2

@onready var _texture_rect: TextureRect = %TextureRect

func _ready() -> void:
	_texture_rect.texture = texture
	texture.region.size = texture_size
	texture.region.position = Vector2.ZERO
	super._ready()

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_texture_rect:
		return
	match button_state:
		ButtonState.NORMAL:
			texture.region.position = Vector2.ZERO
		ButtonState.PRESSED:
			texture.region.position = Vector2(texture_size.x, 0)
		ButtonState.HOVERED:
			texture.region.position = Vector2(texture_size.x*2, 0)
		ButtonState.DISABLED:
			texture.region.position = Vector2(0, texture_size.y)
		ButtonState.SELECTED:
			texture.region.position = Vector2(texture_size.x, texture_size.y)			
