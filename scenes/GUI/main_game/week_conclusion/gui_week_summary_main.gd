class_name GUIWeekSummaryMain
extends Control

signal continue_button_pressed(gold_left:int)

const HIDE_Y := 200
const SHOW_ANIMATION_DURATION := 0.15
const HIDE_ANIMATION_DURATION := 0.15

@onready var _main_panel: PanelContainer = $MainPanel
@onready var _continue_button: GUIRichTextButton = %ContinueButton
@onready var _title: Label = %Title

var _display_y := 0.0
var _gold_left:int

func _ready() -> void:
	_display_y = _main_panel.position.y
	_continue_button.action_evoked.connect(_on_continue_button_pressed)
	_title.text = Util.get_localized_string("WEEK_SUMMARY_TITLE")

func animate_show(current_gold:int, tax:int) -> void:
	show()
	await _play_show_animation()

func _play_show_animation() -> void:
	_main_panel.position.y = HIDE_Y
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", _display_y, SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished
	_continue_button.show()

func animate_hide() -> void:
	_continue_button.hide()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", HIDE_Y, HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()

func _on_continue_button_pressed() -> void:
	await animate_hide()
	continue_button_pressed.emit(_gold_left)
