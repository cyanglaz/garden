class_name GUIChestButton
extends GUIBasicButton

@onready var _nine_patch_rect: NinePatchRect = %NinePatchRect

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_nine_patch_rect:
		return
	match button_state:
		ButtonState.NORMAL:
			_nine_patch_rect.region_rect.position = Vector2(0, 0)
		ButtonState.PRESSED:
			_nine_patch_rect.region_rect.position = Vector2(16, 0)
		ButtonState.HOVERED:
			_nine_patch_rect.region_rect.position = Vector2(32, 0)
		ButtonState.DISABLED:
			_nine_patch_rect.region_rect.position = Vector2(0, 16)
		ButtonState.SELECTED:
			_nine_patch_rect.region_rect.position = Vector2(32, 16)		
