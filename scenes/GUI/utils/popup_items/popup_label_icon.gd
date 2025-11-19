class_name PopupLabelIcon
extends PopupThing

@onready var _label: Label = %Label
@onready var _texture_rect: TextureRect = %TextureRect
@onready var container: HBoxContainer = %Container

var switch_icon_label := false

var _text:String
var _text_color:Color
var _icon:Texture2D

func _ready() -> void:
	super._ready()
	if switch_icon_label:
		_label.move_to_front()
	_setup()

func setup(text:String, text_color:Color = Color.TRANSPARENT, icon:Texture2D = null) -> void:
	_text = text
	_text_color = text_color
	_icon = icon
	_setup()

func _setup() -> void:
	if _label:
		_label.text = _text
		if _text_color != Color.TRANSPARENT:
			_label.add_theme_color_override("font_color", _text_color)
	if _texture_rect && _icon:
		_texture_rect.texture = _icon
