class_name GUIGameOverContainer
extends GUIPopupContainer

const MENU_SCENE_PATH = "res://scenes/GUI/menu/gui_main_menu.tscn"

@onready var ok_button: GUIRichTextButton = %OKButton

func _ready() -> void:
	ok_button.action_evoked.connect(_on_ok_button_action_evoked)

func _on_ok_button_action_evoked() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
