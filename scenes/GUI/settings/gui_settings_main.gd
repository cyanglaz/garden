class_name GUISettingsMain
extends Control

const MENU_SCENE_PATH = "res://scenes/GUI/menu/gui_main_menu.tscn"

# GamePlay settings
@onready var _gui_labeld_slider: GUILabeledSlider = %GUILabeldSlider

# Audio Settings
@onready var _master_audio: GUIAudioSettingSlider = %MasterAudio
@onready var _music_audio: GUIAudioSettingSlider = %MusicAudio
@onready var _sfx_audio: GUIAudioSettingSlider = %SFXAudio

@onready var _default_button: GUIRichTextButton = %DefaultButton
@onready var _back_button: GUIRichTextButton = %BackButton
@onready var _exit_button: GUIRichTextButton = %ExitButton

@onready var _gui_tabbar: GUITabControl = %GUITabbar
@onready var _game_play: VBoxContainer = %GamePlay
@onready var _audios: VBoxContainer = %Audios
@onready var _seed_label: Label = %SeedLabel

func _ready() -> void:
	_master_audio.value_changed.connect(_on_audio_value_changed.bind(PlayerSettings.AudioBus.MASTER))
	_music_audio.value_changed.connect(_on_audio_value_changed.bind(PlayerSettings.AudioBus.MUSIC))
	_sfx_audio.value_changed.connect(_on_audio_value_changed.bind(PlayerSettings.AudioBus.SFX))
	_default_button.pressed.connect(_on_default_button_up)
	_exit_button.pressed.connect(_on_exit_button_up)
	_back_button.pressed.connect(_on_back_button_up)
	_gui_tabbar.tab_selected.connect(_on_gui_tabbar_tab_selected)
	_gui_labeld_slider.value_changed.connect(_on_game_speed_value_changed)
	PlayerSettings.setting_loaded.connect(_reset_ui)
	_reset_ui()

func animate_show() -> void:
	PauseManager.try_pause()
	if Singletons.main_game:
		_seed_label.text = "Seed: %s"%Singletons.main_game.session_seed
	else:
		_seed_label.text = ""
	show()

func animate_hide() -> void:
	PauseManager.try_unpause()
	hide()

func _reset_ui() -> void:
	_master_audio.reset_slider_value()
	_music_audio.reset_slider_value()
	_sfx_audio.reset_slider_value()
	_gui_labeld_slider.set_slider_value_no_signal(PlayerSettings.setting_data.game_speed)

func _on_game_speed_value_changed(value: int) -> void:
	PlayerSettings.update_game_speed(value)

func _on_audio_value_changed(value: float, bus: PlayerSettings.AudioBus) -> void:
	PlayerSettings.update_volume(bus, value)
 
func _on_default_button_up() -> void:
	PlayerSettings.load_default_settings()

func _on_back_button_up() -> void:
	animate_hide()

func _on_exit_button_up() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
	
func _on_gui_tabbar_tab_selected(index:int) -> void:
	match index:
		0:
			_game_play.visible = true
			_audios.visible = false
		1:
			_game_play.visible = false
			_audios.visible = true
