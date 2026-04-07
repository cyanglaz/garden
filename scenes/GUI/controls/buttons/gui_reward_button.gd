class_name GUIRewardButton
extends GUIBasicButton

@onready var background: NinePatchRect = %Background
@onready var gui_icon: GUIIcon = %GUIIcon
@onready var label: Label = %Label

func update_with_texture_and_text(texture: Texture2D, text: String) -> void:
	gui_icon.texture = texture
	label.text = text

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !background:
		return
	match button_state:
		ButtonState.NORMAL:
			background.region_rect.position = Vector2(0, 0)
		ButtonState.PRESSED:
			background.region_rect.position = Vector2(16, 0)
		ButtonState.HOVERED:
			background.region_rect.position = Vector2(32, 0)
		ButtonState.DISABLED:
			background.region_rect.position = Vector2(0, 16)
		ButtonState.SELECTED:
			background.region_rect.position = Vector2(16, 16)
