class_name GUIWeekSummaryMain
extends Control

const SUMMARY_AUDIO_1 := preload("res://resources/sounds/SFX/summary/summary_1.wav")
const SUMMARY_AUDIO_2 := preload("res://resources/sounds/SFX/summary/summary_2.wav")
const SUMMARY_AUDIO_3 := preload("res://resources/sounds/SFX/summary/summary_3.wav")

const MENU_SCENE_PATH = "res://scenes/GUI/menu/gui_main_menu.tscn"

signal continue_button_pressed(gold_left:int)

const HIDE_Y := 200
const SHOW_ANIMATION_DURATION := 0.15
const HIDE_ANIMATION_DURATION := 0.15
const DISPLAY_ITEMS_DELAY := 0.1

@onready var _main_panel: PanelContainer = $MainPanel
@onready var _continue_button: GUIRichTextButton = %ContinueButton
@onready var _title: Label = %Title
@onready var _earned: GUISummaryItem = %Earned
@onready var _tax: GUISummaryItem = %Tax
@onready var _conclusion: GUISummaryItem = %Conclusion
@onready var _gui_tooltip_description_saparator: HSeparator = %GUITooltipDescriptionSaparator
@onready var _item_audio_player: AudioStreamPlayer2D = %ItemAudioPlayer

var _display_y := 0.0
var _gold_left:int

func _ready() -> void:
	_display_y = _main_panel.position.y
	_continue_button.action_evoked.connect(_on_continue_button_pressed)
	_title.text = Util.get_localized_string("WEEK_SUMMARY_TITLE")

func animate_show(current_gold:int, tax:int) -> void:
	show()
	_continue_button.hide()
	await _play_show_animation()
	_earned.update_with_title_and_gold(tr("WEEK_SUMMARY_EARNED_TITLE"), current_gold, Constants.COLOR_WHITE)
	_tax.update_with_title_and_gold(tr("WEEK_SUMMARY_TAX_TITLE"), tax, Constants.COLOR_WHITE)
	_gold_left = current_gold - tax
	var conclusion_color := Constants.COLOR_WHITE
	if _gold_left >= 0:
		conclusion_color = Constants.COLOR_GREEN3
		_set_button_to_success()
	elif _gold_left < 0:
		conclusion_color = Constants.COLOR_RED
		_set_button_to_failure()
	_conclusion.update_with_title_and_gold(tr("WEEK_SUMMARY_CONCLUSION_TITLE"), _gold_left, conclusion_color)
	await _play_display_items_animation()

func _play_show_animation() -> void:
	_main_panel.position.y = HIDE_Y
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", _display_y, SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished

func _play_display_items_animation() -> void:
	_earned.hide()
	_tax.hide()
	_conclusion.hide()
	_gui_tooltip_description_saparator.hide()
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
	_earned.show()
	_item_audio_player.stream = SUMMARY_AUDIO_1
	_item_audio_player.play()
	await _item_audio_player.finished
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
	_tax.show()
	_item_audio_player.stream = SUMMARY_AUDIO_2
	_item_audio_player.play()
	await _item_audio_player.finished
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
	_gui_tooltip_description_saparator.show()
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY * 2).timeout
	_conclusion.show()
	_item_audio_player.stream = SUMMARY_AUDIO_3
	_item_audio_player.play()
	await _item_audio_player.finished
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
	_continue_button.show()

func animate_hide() -> void:
	_continue_button.hide()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", HIDE_Y, HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()

func _set_button_to_success() -> void:
	_continue_button.localization_text_key = "WEEK_SUMMARY_SUCCESS_BUTTON"

func _set_button_to_failure() -> void:
	_continue_button.localization_text_key = "WEEK_SUMMARY_FAILURE_BUTTON"

func _on_continue_button_pressed() -> void:
	if _gold_left >= 0:
		await animate_hide()
		continue_button_pressed.emit(_gold_left)
	else:
		get_tree().change_scene_to_file(MENU_SCENE_PATH)
