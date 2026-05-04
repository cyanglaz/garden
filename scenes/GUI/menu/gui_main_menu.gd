class_name GUIMainMenu
extends CanvasLayer

const SLIDE_DURATION := 0.3
const SLIDE_STAGGER := 0.06

@onready var _new_game_button: GUIMenuButton = %NewGameButton
@onready var _options_button: GUIMenuButton = %OptionsButton
@onready var _credits_button: GUIMenuButton = %CreditsButton
@onready var _exit_button: GUIMenuButton = %ExitButton
@onready var _gui_settings_main: GUISettingsMain = %GUISettingsMain
@onready var _gui_credits_panel: GUICreditsPanel = %GUICreditsPanel
@onready var _version_label: Label = %VersionLabel
@onready var _animation_player: AnimationPlayer = %AnimationPlayer

func _ready():
	PauseManager.try_unpause()
	_new_game_button.pressed.connect(_on_new_game_button_pressed)
	_options_button.pressed.connect(_on_options_button_pressed)
	_exit_button.pressed.connect(_on_exit_button_pressed)
	_credits_button.pressed.connect(_on_credits_button_pressed)
	_new_game_button.grab_focus()
	_version_label.text = str("v.",ProjectSettings.get_setting("application/config/version"))
	_animate_buttons_slide_in()
	_animation_player.play("default")

func _animate_buttons_slide_in() -> void:
	var buttons: Array[Control] = [_new_game_button, _options_button, _credits_button, _exit_button]
	await get_tree().process_frame
	var natural_x: Array[float] = []
	for button in buttons:
		natural_x.append(button.position.x)
		button.position.x -= 400.0
	var tween := Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for i in buttons.size():
		tween.tween_property(buttons[i], "position:x", natural_x[i], SLIDE_DURATION) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT) \
			.set_delay(i * SLIDE_STAGGER)

func _on_new_game_button_pressed() -> void:
	Main.weak_main().get_ref().show_game_session()

func _on_options_button_pressed() -> void:
	_gui_settings_main.animate_show()

func _on_credits_button_pressed() -> void:
	_gui_credits_panel.animate_show()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
