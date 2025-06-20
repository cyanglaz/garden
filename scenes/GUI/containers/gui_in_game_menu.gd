class_name GUIInGameMenuContainer
extends GUIPopupContainer

const MAIN_MENU_SCENE := "res://scenes/GUI/menu/gui_main_menu.tscn"

@onready var _continue_button: GUIMenuButton = %ContinueButton
@onready var _options_button: GUIMenuButton = %OptionsButton
@onready var _main_menu_button: GUIMenuButton = %MainMenuButton

func _ready() -> void:
	_continue_button.action_evoked.connect(_on_continue_button_evoked)
	_options_button.action_evoked.connect(_on_options_button_evoked)
	_main_menu_button.action_evoked.connect(_on_main_menu_button_evoked)

func _on_continue_button_evoked() -> void:
	animate_hide()

func _on_options_button_evoked() -> void:
	await animate_hide()
	PauseManager.try_pause()
	var settings_menu:GUISettingsMenu = Util.show_settings()
	settings_menu.dismissed.connect(_on_settings_menu_dismissed)

func _on_main_menu_button_evoked() -> void:
	PauseManager.try_unpause()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_settings_menu_dismissed() -> void:
	animate_show()
