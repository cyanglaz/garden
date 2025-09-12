class_name GUIDemoEndContainer
extends GUIPopupContainer

const MENU_SCENE_PATH = "res://scenes/GUI/menu/gui_main_menu.tscn"

@onready var ok_button: GUIRichTextButton = %OKButton

func _ready() -> void:
	ok_button.pressed.connect(_on_ok_button_pressed)

func _on_ok_button_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
