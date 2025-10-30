class_name GUIChestRewardItem
extends PanelContainer

signal get_button_pressed()

@onready var gui_rich_text_button: GUIRichTextButton = %GUIRichTextButton

func _ready() -> void:
	gui_rich_text_button.pressed.connect(_on_get_button_pressed)

func _on_get_button_pressed() -> void:
	get_button_pressed.emit()
