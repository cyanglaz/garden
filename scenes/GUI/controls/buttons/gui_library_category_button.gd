class_name GUILibraryCategoryButton
extends GUIBasicButton

@export var icon:Texture2D
@export var localized_text:String

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label

func _ready() -> void:
	texture_rect.texture = icon
	label.text = Util.get_localized_string(localized_text)
