class_name GUIGameOverMain
extends Control

const MENU_SCENE_PATH = "res://scenes/GUI/menu/gui_main_menu.tscn"

const DISPLAY_ITEMS_DELAY := 0.1
const HIDE_Y := 200
const SHOW_ANIMATION_DURATION := 0.15
const HIDE_ANIMATION_DURATION := 0.15

@onready var _level_label: GUISummaryItem = %LevelLabel
@onready var _total_days_skipped_label: GUISummaryItem = %TotalDaysSkippedLabel
@onready var _total_gold_earned_label: GUISummaryItem = %TotalGoldEarnedLabel
@onready var _continue_button: GUIRichTextButton = %ContinueButton
@onready var _title: Label = %Title
@onready var _main_panel: PanelContainer = %MainPanel

var _display_y := 0.0

func _ready() -> void:
	_display_y = _main_panel.position.y
	_continue_button.action_evoked.connect(_on_continue_button_pressed)
	_title.text = Util.get_localized_string("GAME_OVER_TITLE")

func animate_show(session_summary:SessionSummary) -> void:
	_continue_button.hide()
	show()
	_level_label.value_text = str(session_summary.level + 1)
	_total_days_skipped_label.value_text = str(session_summary.total_days_skipped)
	_total_gold_earned_label.value_text = str(session_summary.total_gold_earned)

	await _play_show_animation()
	await Util.create_scaled_timer(DISPLAY_ITEMS_DELAY).timeout
	_continue_button.show()

func _play_show_animation() -> void:
	_main_panel.position.y = HIDE_Y
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", _display_y, SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished

func animate_hide() -> void:
	_continue_button.hide()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", HIDE_Y, HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()

func _on_continue_button_pressed() -> void:
	await animate_hide()
	get_tree().change_scene_to_file(MENU_SCENE_PATH)
