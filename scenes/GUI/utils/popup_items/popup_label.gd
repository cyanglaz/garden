class_name PopupLabel
extends PopupThing

@onready var label: Label = %Label

var _text:String
var _text_color:Color
var _font_size:int

func _ready() -> void:
	super._ready()
	_setup()

func setup(text:String, text_color:Color = Color.TRANSPARENT, font_size:int = -1) -> void:
	_text = text
	_text_color = text_color
	_font_size = font_size
	_setup()

func _setup() -> void:
	if label:
		label.text = _text
		if _text_color != Color.TRANSPARENT:
			label.add_theme_color_override("font_color", _text_color)
		if _font_size > 0:
			label.add_theme_font_size_override("font_size", _font_size)