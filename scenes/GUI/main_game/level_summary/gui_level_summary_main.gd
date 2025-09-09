class_name GUILevelSummaryMain
extends Control

const SUMMARY_AUDIO_1 := preload("res://resources/sounds/SFX/summary/summary_1.wav")
const SUMMARY_AUDIO_2 := preload("res://resources/sounds/SFX/summary/summary_2.wav")
const SUMMARY_AUDIO_3 := preload("res://resources/sounds/SFX/summary/summary_3.wav")
const FAILURE_MESSAGE_AUDIO = preload("res://resources/sounds/SFX/summary/failure_message.wav")

const MENU_SCENE_PATH = "res://scenes/GUI/menu/gui_main_menu.tscn"

signal continue_button_pressed()
signal gold_increased(gold:int)

const HIDE_Y := 200
const SHOW_ANIMATION_DURATION := 0.15
const HIDE_ANIMATION_DURATION := 0.15
const DISPLAY_ITEMS_DELAY := 0.1
const FINAL_GOLD_INCREASE_DELAY := 0.2

const BASE_GOLD := 6
const GOLD_PER_DAY_LEFT := 3

@onready var _main_panel: PanelContainer = $MainPanel
@onready var _continue_button: GUIRichTextButton = %ContinueButton
@onready var _title: Label = %Title
@onready var _days_left_label: GUISummaryItem = %DaysLeftLabel
@onready var _gui_gold: GUIGold = %GUIGold

@onready var _item_audio_player: AudioStreamPlayer2D = %ItemAudioPlayer

var _display_y := 0.0
var _days_left := 0

func _ready() -> void:
	_display_y = _main_panel.position.y
	_continue_button.action_evoked.connect(_on_continue_button_pressed)
	_title.text = Util.get_localized_string("WEEK_SUMMARY_TITLE")
	_gui_gold.gold_incremented.connect(_on_gold_incremented)

func animate_show(days_left:int) -> void:
	_days_left = days_left
	_continue_button.hide()
	show()
	_gui_gold.update_gold(0, GUIGold.AnimationType.NONE)
	_days_left_label.value_text = ""
	await _play_show_animation()
	
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
	_days_left_label.value_text = str(days_left)
	_item_audio_player.stream = SUMMARY_AUDIO_1
	_item_audio_player.play()
	await _item_audio_player.finished
	
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY * 2).timeout
	_gui_gold.update_gold(BASE_GOLD, GUIGold.AnimationType.NONE)
	_item_audio_player.stream = SUMMARY_AUDIO_3
	_item_audio_player.play()
	await _item_audio_player.finished
	
	await _play_earn_gold_animation()
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
	_continue_button.show()

func _play_show_animation() -> void:
	_main_panel.position.y = HIDE_Y
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", _display_y, SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished

func _play_earn_gold_animation() -> void:
	var total := BASE_GOLD + _days_left * GOLD_PER_DAY_LEFT
	await _gui_gold.update_gold(total, GUIGold.AnimationType.SINGLE, GOLD_PER_DAY_LEFT)
	await Util.create_scaled_timer(FINAL_GOLD_INCREASE_DELAY).timeout
	gold_increased.emit(total)

func animate_hide() -> void:
	_continue_button.hide()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", HIDE_Y, HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()

func _on_continue_button_pressed() -> void:
	await animate_hide()
	continue_button_pressed.emit()

func _on_gold_incremented(step:int) -> void:
	_days_left_label.value_text = str(_days_left - step - 1)
