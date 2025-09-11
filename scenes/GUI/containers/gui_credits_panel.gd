class_name GUICreditsPanel
extends GUIPopupContainer

@onready var _back_button: GUIRichTextButton = %BackButton

func _ready() -> void:
	_back_button.pressed.connect(_on_back_button_up)

func _on_back_button_up() -> void:
	animate_hide()
