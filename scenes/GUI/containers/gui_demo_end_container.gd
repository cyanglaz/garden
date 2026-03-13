class_name GUIDemoEndContainer
extends GUIPopupContainer

const MENU_SCENE_PATH = "res://scenes/GUI/menu/gui_main_menu.tscn"

@onready var ok_button: GUIRichTextButton = %OKButton
@onready var _title_label: Label = %Label
@onready var _subtitle_label: Label = %Label2

func _ready() -> void:
	_title_label.text = Util.get_localized_string("DEMO_END_TITLE")
	_subtitle_label.text = Util.get_localized_string("DEMO_END_SUBTITLE")
	ok_button.pressed.connect(_on_ok_button_pressed)

func _on_ok_button_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
