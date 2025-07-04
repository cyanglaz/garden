class_name PopupLabelIcon
extends PopupThing

@onready var _label: Label = %Label
@onready var _texture_rect: TextureRect = %TextureRect

func setup(text:String, text_color:Color, icon:Texture2D) -> void:
	_label.text = text
	_label.add_theme_color_override("font_color", text_color)
	_texture_rect.texture = icon
