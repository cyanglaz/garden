class_name GUIGameOverMain
extends Control

const MENU_SCENE_PATH = "res://scenes/GUI/menu/gui_main_menu.tscn"

const DISPLAY_ITEMS_DELAY := 0.1

@onready var _continue_button: GUIRichTextButton = %ContinueButton
@onready var _title: Label = %Title

func _ready() -> void:
	_continue_button.pressed.connect(_on_continue_button_pressed)
	_title.text = Util.get_localized_string("GAME_OVER_TITLE")

func animate_show() -> void:
	PauseManager.try_pause()
	_continue_button.hide()
	show()
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
	_continue_button.show()

func _on_continue_button_pressed() -> void:
	hide()
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
