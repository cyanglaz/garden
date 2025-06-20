class_name GUIBasicToggleButton
extends GUIBasicButton

signal toggled(on:bool)

@export var localization_text_key:String: set = _set_localization_text_key

@onready var label: Label = %Label
@onready var texture_rect: TextureRect = %TextureRect

var on:bool = false

func _ready() -> void:
	super._ready()
	action_evoked.connect(_on_toggled)
	_set_localization_text_key(localization_text_key)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !texture_rect:
		return
	var position_y := 0
	if on:
		position_y = 8
	match button_state:
		ButtonState.NORMAL:
			(texture_rect.texture as AtlasTexture).region.position = Vector2(0, position_y)
		ButtonState.PRESSED:
			(texture_rect.texture as AtlasTexture).region.position = Vector2(16, position_y)
		ButtonState.HOVERED:
			(texture_rect.texture as AtlasTexture).region.position = Vector2(32, position_y)
		ButtonState.DISABLED:
			(texture_rect.texture as AtlasTexture).region.position = Vector2(0, 16)
		ButtonState.SELECTED:
			assert(false, "SELECTED state not supported for check button")

func _set_localization_text_key(val:String) -> void:
	localization_text_key = val
	if label:
		label.text = tr(localization_text_key)

func _on_toggled() -> void:
	on = !on
	_set_button_state(button_state)
	toggled.emit(on)
