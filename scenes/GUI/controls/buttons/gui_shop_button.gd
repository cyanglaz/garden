extends GUIBasicButton

const TEXTURE_SIZE := 16

@onready var _background: NinePatchRect = %Background

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_background:
		return
	match button_state:
		ButtonState.NORMAL:
			_background.region_rect.position = Vector2.ZERO
		ButtonState.PRESSED:
			_background.region_rect.position = Vector2(TEXTURE_SIZE, 0)
		ButtonState.HOVERED:
			_background.region_rect.position = Vector2(TEXTURE_SIZE*2, 0)
		ButtonState.DISABLED:
			_background.region_rect.position = Vector2(0, TEXTURE_SIZE)
		ButtonState.SELECTED:
			_background.region_rect.position = Vector2(TEXTURE_SIZE, TEXTURE_SIZE)			
