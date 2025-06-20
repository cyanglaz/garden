class_name GUISettingsMenu
extends GUIPopupContainer

# Audio Settings
@onready var _master_audio: GUIAudioSettingSlider = %MasterAudio
@onready var _music_audio: GUIAudioSettingSlider = %MusicAudio
@onready var _sfx_audio: GUIAudioSettingSlider = %SFXAudio

@onready var _cancel_button: GUIRichTextButton = %CancelButton
@onready var _save_button: GUIRichTextButton = %SaveButton
@onready var _default_button: GUIRichTextButton = %DefaultButton
@onready var _back_button: GUIRichTextButton = %BackButton

@onready var _gui_tabbar: GUITabControl = %GUITabbar
@onready var _game_play: VBoxContainer = %GamePlay
@onready var _audios: VBoxContainer = %Audios


func _ready() -> void:
	_master_audio.value_changed.connect(_on_audio_value_changed.bind(PlayerSettings.AudioBus.MASTER))
	_music_audio.value_changed.connect(_on_audio_value_changed.bind(PlayerSettings.AudioBus.MUSIC))
	_sfx_audio.value_changed.connect(_on_audio_value_changed.bind(PlayerSettings.AudioBus.SFX))
	_cancel_button.action_evoked.connect(_on_cancel_button_up)
	_save_button.action_evoked.connect(_on_apply_button_up)
	_default_button.action_evoked.connect(_on_default_button_up)
	_back_button.action_evoked.connect(_on_back_button_up)
	_gui_tabbar.tab_selected.connect(_on_gui_tabbar_tab_selected)
	PlayerSettings.setting_loaded.connect(_reset_ui)
	_reset_ui()

func _reset_ui() -> void:
	_master_audio.reset_slider_value()
	_music_audio.reset_slider_value()
	_sfx_audio.reset_slider_value()

func _on_audio_value_changed(value: float, bus: PlayerSettings.AudioBus) -> void:
	PlayerSettings.update_volume(bus, value)

func _on_cancel_button_up() -> void:
	PlayerSettings.load_setings_from_save()

func _on_apply_button_up() -> void:
	PlayerSettings.save_settings()

func _on_default_button_up() -> void:
	PlayerSettings.load_default_settings()

func _on_back_button_up() -> void:
	animate_hide()
	
func _on_gui_tabbar_tab_selected(index:int) -> void:
	match index:
		0:
			_game_play.visible = true
			_audios.visible = false
		1:
			_game_play.visible = false
			_audios.visible = true
