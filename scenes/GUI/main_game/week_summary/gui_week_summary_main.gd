class_name GUIWeekSummaryMain
extends Control

const SUMMARY_AUDIO_1 := preload("res://resources/sounds/SFX/summary/summary_1.wav")
const SUMMARY_AUDIO_2 := preload("res://resources/sounds/SFX/summary/summary_2.wav")
const SUMMARY_AUDIO_3 := preload("res://resources/sounds/SFX/summary/summary_3.wav")
const FAILURE_MESSAGE_AUDIO = preload("res://resources/sounds/SFX/summary/failure_message.wav")

const MENU_SCENE_PATH = "res://scenes/GUI/menu/gui_main_menu.tscn"

signal continue_button_pressed()

const HIDE_Y := 200
const SHOW_ANIMATION_DURATION := 0.15
const HIDE_ANIMATION_DURATION := 0.15
const DISPLAY_ITEMS_DELAY := 0.1

@onready var _main_panel: PanelContainer = $MainPanel
@onready var _continue_button: GUIRichTextButton = %ContinueButton
@onready var _main_menu_button: GUIRichTextButton = %MainMenuButton
@onready var _title: Label = %Title
@onready var _earned: GUISummaryItem = %Earned
@onready var _tax: GUISummaryItem = %Tax
@onready var _conclusion: GUISummaryItem = %Conclusion
@onready var _gui_tooltip_description_saparator: HSeparator = %GUITooltipDescriptionSaparator
@onready var _item_audio_player: AudioStreamPlayer2D = %ItemAudioPlayer
@onready var _failed_label: Label = %FailedLabel

var _display_y := 0.0
var _success := false

func _ready() -> void:
	_display_y = _main_panel.position.y
	_continue_button.action_evoked.connect(_on_continue_button_pressed)
	_main_menu_button.action_evoked.connect(_on_main_menu_button_pressed)
	_title.text = Util.get_localized_string("WEEK_SUMMARY_TITLE")
	_failed_label.text = Util.get_localized_string("WEEK_SUMMARY_FAILURE_MESSAGE")

func animate_show(point:int, due:int) -> void:
	_continue_button.hide()
	_earned.hide()
	_tax.hide()
	_conclusion.hide()
	_gui_tooltip_description_saparator.hide()
	_failed_label.hide()
	_main_menu_button.hide()
	show()
	_earned.update_with_title_and_points(tr("WEEK_SUMMARY_EARNED_TITLE"), point, Constants.COLOR_WHITE)
	_tax.update_with_title_and_points(tr("WEEK_SUMMARY_DUE_TITLE"), due, Constants.COLOR_WHITE)
	_success = point >= due
	await _play_show_animation()
	await _play_display_items_animation()

func _play_show_animation() -> void:
	_main_panel.position.y = HIDE_Y
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", _display_y, SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished

func _play_display_items_animation() -> void:	
	# Show earned
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
	_earned.show()
	_item_audio_player.stream = SUMMARY_AUDIO_1
	_item_audio_player.play()
	await _item_audio_player.finished
	
	# Show tax
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
	_tax.show()
	_item_audio_player.stream = SUMMARY_AUDIO_2
	_item_audio_player.play()
	await _item_audio_player.finished
	
	# Show separator
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
	_gui_tooltip_description_saparator.show()
	
	# Show summary
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY * 2).timeout
	_conclusion.show()
	_item_audio_player.stream = SUMMARY_AUDIO_3
	_item_audio_player.play()
	await _item_audio_player.finished
	
	# Show failure message and button
	if _success:
		await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
		_continue_button.show()
	else:
		await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
		_failed_label.show()
		_item_audio_player.stream = FAILURE_MESSAGE_AUDIO
		_item_audio_player.play()
		await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
		_main_menu_button.show()

func animate_hide() -> void:
	_continue_button.hide()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", HIDE_Y, HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()

func _on_continue_button_pressed() -> void:
	await animate_hide()
	continue_button_pressed.emit()

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
