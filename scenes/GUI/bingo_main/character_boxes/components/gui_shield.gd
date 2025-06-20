class_name GUIShield
extends TextureRect

@onready var label: Label = %Label

var _shield_texture:Texture

func _ready() -> void:
	_shield_texture = texture

func set_shield(val:int) -> void:
	if val <= 0:
		texture = null
		label.text = ""
		return
	texture = _shield_texture
	label.text = str(val)
