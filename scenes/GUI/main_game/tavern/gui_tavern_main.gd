class_name GUITavernMain
extends CanvasLayer

signal tavern_finished()

const RATING_GAIN_FREE := 5
const RATING_GAIN_PAID := 15
const RATING_GAIN_PAID_COST := 12
const GOLD_GAIN := 18
const EVENT_BUTTON_SCENE := preload("res://scenes/GUI/controls/buttons/gui_event_selection_button.tscn")

@onready var _main_panel: PanelContainer = %MainPanel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var buttons_container: VBoxContainer = %ButtonsContainer
@onready var free_rating_button: GUIEventSelectionButton = %FreeRatingButton
@onready var paid_rating_button: GUIEventSelectionButton = %PaidRatingButton
@onready var gain_gold_button: GUIEventSelectionButton = %GainGoldButton

var _display_y := 0.0

func _ready() -> void:
	_display_y = _main_panel.position.y
	description_label.text = Util.get_localized_string("TAVERN_DESCRIPTION")
	free_rating_button.label.text = DescriptionParser.format_references(Util.get_localized_string("TAVERN_FREE_RATING") % RATING_GAIN_FREE, {}, {}, func(_reference_id:String) -> bool: return false)
	paid_rating_button.label.text = DescriptionParser.format_references(Util.get_localized_string("TAVERN_PAID_RATING") % [RATING_GAIN_PAID_COST, RATING_GAIN_PAID], {}, {}, func(_reference_id:String) -> bool: return false)
	gain_gold_button.label.text = DescriptionParser.format_references(Util.get_localized_string("TAVERN_GAIN_GOLD") % GOLD_GAIN, {}, {}, func(_reference_id:String) -> bool: return false)
	free_rating_button.pressed.connect(_on_free_rating_button_pressed)
	paid_rating_button.pressed.connect(_on_paid_rating_button_pressed)
	gain_gold_button.pressed.connect(_on_gain_gold_button_pressed)

func animate_show() -> void:
	show()
	await _play_show_animation()

func _animate_hide() -> void:
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", Constants.PENEL_HIDE_Y, Constants.HIDE_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()

func _play_show_animation() -> void:
	_main_panel.position.y = Constants.PENEL_HIDE_Y
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_main_panel, "position:y", _display_y, Constants.SHOW_ANIMATION_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished

func _finish() -> void:
	await _animate_hide()
	tavern_finished.emit()

func _on_free_rating_button_pressed() -> void:
	Events.request_rating_update.emit(RATING_GAIN_FREE)
	_finish()

func _on_paid_rating_button_pressed() -> void:
	Events.request_rating_update.emit(RATING_GAIN_PAID)
	Events.request_update_gold.emit(-RATING_GAIN_PAID_COST, false)
	_finish()

func _on_gain_gold_button_pressed() -> void:
	Events.request_update_gold.emit(GOLD_GAIN, false)
	_finish()
