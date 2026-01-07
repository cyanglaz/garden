class_name GUIImageButton
extends GUIBasicButton

@export var image_size:Vector2i
@export var flip_image_h:bool
@export var flip_image_v:bool

@onready var _texture_rect: TextureRect = %TextureRect

func _ready() -> void:
	super._ready()
	if flip_image_h:
		_texture_rect.flip_h = true
	if flip_image_v:
		_texture_rect.flip_v = true

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_texture_rect || !_texture_rect.texture:
		return
	match button_state:
		ButtonState.NORMAL:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(0, 0)
		ButtonState.PRESSED:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(image_size.x, 0)
		ButtonState.HOVERED:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(image_size.x*2, 0)
		ButtonState.DISABLED:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(0, image_size.y)
		ButtonState.SELECTED:
			(_texture_rect.texture as AtlasTexture).region.position = Vector2(image_size.x*2, image_size.y)		
