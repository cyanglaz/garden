class_name GUIUseCardButton
extends GUIBasicButton

@onready var background: NinePatchRect = %Background
@onready var label: Label = %Label

func _ready() -> void:
	super._ready()
	label.text = Util.get_localized_string("ACTION_USE_CARD")

func _set_button_state(val:ButtonState) -> void:
	if button_state == ButtonState.PRESSED && label:
		label.position.y -= 1
	super._set_button_state(val)
	if !label:
		return
	match button_state:
		ButtonState.NORMAL:
			background.region_rect.position = Vector2(0, 0)
		ButtonState.PRESSED:
			background.region_rect.position = Vector2(16, 0)
			label.position.y += 1
		ButtonState.HOVERED:
			background.region_rect.position = Vector2(32, 0)
		ButtonState.DISABLED:
			background.region_rect.position = Vector2(0, 16)
		ButtonState.SELECTED:
			background.region_rect.position = Vector2(16, 16)
