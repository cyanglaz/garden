class_name GUITabbarButton
extends GUIBasicButton

@export var localization_text_key:String: set = _set_localization_text_key

@onready var _border: NinePatchRect = %Border
@onready var _label: Label = %Label
@onready var _margin_container: MarginContainer = %MarginContainer

var _label_default_position:Vector2

func _ready() -> void:
	super._ready()
	_label.text = tr(localization_text_key)
	_label_default_position = _margin_container.position

func _set_localization_text_key(key:String) -> void:
	localization_text_key = key
	if _label:
		_label.text = tr(localization_text_key)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_label:
		return
	match button_state:
		ButtonState.NORMAL:
			_margin_container.position = _label_default_position
			_label.add_theme_color_override("font_color", Constants.COLOR_WHITE)
			_border.region_rect.position = Vector2(0, 0)
		ButtonState.PRESSED:
			_margin_container.position = _label_default_position + Vector2.DOWN * 2
			_label.add_theme_color_override("font_color", Constants.COLOR_WHITE)
			_border.region_rect.position = Vector2(16, 0)
		ButtonState.HOVERED:
			_margin_container.position = _label_default_position
			_label.add_theme_color_override("font_color", Constants.COLOR_WHITE)
			_border.region_rect.position = Vector2(32, 0)
		ButtonState.DISABLED:
			_margin_container.position = _label_default_position
			_label.add_theme_color_override("font_color", Constants.COLOR_WHITE)
			_border.region_rect.position = Vector2(0, 16)
		ButtonState.SELECTED:
			_margin_container.position = _label_default_position + Vector2.UP * 2
			_label.add_theme_color_override("font_color", Constants.COLOR_WHITE)	
			_border.region_rect.position = Vector2(16, 16)
