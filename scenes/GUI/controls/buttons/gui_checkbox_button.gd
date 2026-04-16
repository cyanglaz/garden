class_name GUICheckBoxButton
extends GUIBasicButton

const SIZE := Vector2(12, 12)

signal checked(on:bool)

@onready var texture_rect: TextureRect = %TextureRect

var on:bool = false

func _ready() -> void:
	super._ready()
	pressed.connect(_on_checked)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !texture_rect:
		return
	var position_y := 0.0
	if on:
		position_y = SIZE.y
	match button_state:
		ButtonState.NORMAL:
			(texture_rect.texture as AtlasTexture).region.position = Vector2(0, position_y)
		ButtonState.PRESSED:
			(texture_rect.texture as AtlasTexture).region.position = Vector2(SIZE.x, position_y)
		ButtonState.HOVERED:
			(texture_rect.texture as AtlasTexture).region.position = Vector2(SIZE.x*2, position_y)
		ButtonState.DISABLED:
			(texture_rect.texture as AtlasTexture).region.position = Vector2(0, SIZE.y*2)
		ButtonState.SELECTED:
			assert(false, "SELECTED state not supported for check button")

func _on_checked() -> void:
	on = !on
	_set_button_state(button_state)
	checked.emit(on)
