@tool
class_name GUIMenuButton
extends GUIBasicButton

@export var localization_text_key:String: set = _set_localization_text_key

@onready var _label: Label = %Label

func _ready() -> void:
	super._ready()
	_label.text = tr(localization_text_key)

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
			_label.add_theme_color_override("font_color", Constants.MENU_BUTTON_NORMAL_COLOR)
		ButtonState.PRESSED:
			_label.add_theme_color_override("font_color", Constants.MENU_BUTTON_PRESSED_COLOR)
		ButtonState.HOVERED:
			_label.add_theme_color_override("font_color", Constants.MENU_BUTTON_HOVERED_COLOR)
		ButtonState.DISABLED:
			_label.add_theme_color_override("font_color", Constants.MENU_BUTTON_DISABLED_COLOR)
		ButtonState.SELECTED:
			_label.add_theme_color_override("font_color", Constants.MENU_BUTTON_SELECTED_COLOR)	
