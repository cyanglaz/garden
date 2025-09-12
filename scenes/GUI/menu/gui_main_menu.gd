class_name MainMenu
extends CanvasLayer

const LEVEL_SCENE_PATH = "res://scenes/game_session/game_level.tscn"
const SCENE_PATH = "res://scenes/main_game/main_game.tscn"

@onready var _new_game_button: GUIMenuButton = %NewGameButton
@onready var _options_button: GUIMenuButton = %OptionsButton
@onready var _credits_button: GUIMenuButton = %CreditsButton
@onready var _exit_button: GUIMenuButton = %ExitButton
@onready var _gui_settings_main: GUISettingsMain = %GUISettingsMain
@onready var _gui_credits_panel: GUICreditsPanel = %GUICreditsPanel
@onready var _version_label: Label = %VersionLabel

func _ready():
	PauseManager.try_unpause()
	_new_game_button.pressed.connect(_on_new_game_button_pressed)
	_options_button.pressed.connect(_on_options_button_pressed)
	_exit_button.pressed.connect(_on_exit_button_pressed)
	_credits_button.pressed.connect(_on_credits_button_pressed)
	_new_game_button.grab_focus()
	_version_label.text = str("v.",ProjectSettings.get_setting("application/config/version"))
	
func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file(SCENE_PATH)
	#Main.weak_main().get_ref().show_game_session()

func _on_options_button_pressed() -> void:
	_gui_settings_main.animate_show()

func _on_credits_button_pressed() -> void:
	_gui_credits_panel.animate_show()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
func _on_setting_menu_closed():
	_options_button.grab_focus()
