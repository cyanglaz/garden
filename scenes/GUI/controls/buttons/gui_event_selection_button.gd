class_name GUIEventSelectionButton
extends GUIBasicButton

@export var localized_text:String

@onready var border: NinePatchRect = %Border
@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label

func _ready() -> void:
	label.text = Util.get_localized_string(localized_text)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if border:
		match button_state:
			ButtonState.NORMAL:
				mouse_filter = Control.MOUSE_FILTER_STOP
				border.region_rect.position = Vector2(0, 0)
			ButtonState.PRESSED:
				mouse_filter = Control.MOUSE_FILTER_STOP
				border.region_rect.position = Vector2(16, 0)
			ButtonState.HOVERED:
				mouse_filter = Control.MOUSE_FILTER_STOP
				border.region_rect.position = Vector2(32, 0)
			ButtonState.DISABLED:
				border.region_rect.position = Vector2(0, 16)
			ButtonState.SELECTED:
				mouse_filter = Control.MOUSE_FILTER_IGNORE
				border.region_rect.position = Vector2(16, 16)
