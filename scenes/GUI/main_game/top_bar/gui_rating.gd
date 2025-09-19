class_name GUIRating
extends HBoxContainer

const POPUP_LABEL_SCENE := preload("res://scenes/GUI/utils/popup_items/popup_label.tscn")

signal rating_update_finished(value:int)

const RATING_SAFE_COLOR := Constants.COLOR_YELLOW2
const RATING_MODERATE_COLOR := Constants.COLOR_ORANGE1
const RATING_DANGER_COLOR := Constants.COLOR_ORANGE4
const RATING_SAFE_TEXT_COLOR := Constants.COLOR_WHITE
const RATING_MODERATE_TEXT_COLOR := Constants.COLOR_YELLOW1
const RATING_DANGER_TEXT_COLOR := Constants.COLOR_RED1
const RATING_MODERATE_PERCENTAGE := 0.6
const RATING_DANGER_PERCENTAGE := 0.2
const POPUP_SHOW_TIME := 0.5
const POPUP_DESTROY_TIME := 0.5

@onready var gui_bordered_progress_bar: GUIProgressBar = %GUIBorderedProgressBar
@onready var rich_text_label: RichTextLabel = %RichTextLabel

var _current_value:int = -1

func _ready() -> void:
	gui_bordered_progress_bar.animate_set_value_finished.connect(func(value:int): rating_update_finished.emit(value))

func bind_with_rating(rating:ResourcePoint) -> void:
	rating.value_update.connect(_on_rating_value_update.bind(rating))
	rating.max_value_update.connect(_on_rating_value_update.bind(rating))
	_on_rating_value_update(rating)

func _on_rating_value_update(rating:ResourcePoint) -> void:
	gui_bordered_progress_bar.max_value = rating.max_value
	if _current_value >= 0:
		var diff = rating.value - _current_value
		_play_animation(diff)
	_current_value = rating.value
	gui_bordered_progress_bar.animated_set_value(rating.value)
	var tint_color:Color = RATING_SAFE_COLOR
	var text_color:Color = RATING_SAFE_TEXT_COLOR
	var percentage:float = (rating.value as float) / rating.max_value
	if percentage >= RATING_MODERATE_PERCENTAGE:
		tint_color = RATING_SAFE_COLOR
		text_color = RATING_SAFE_TEXT_COLOR
	elif percentage >= RATING_DANGER_PERCENTAGE:
		tint_color = RATING_MODERATE_COLOR
		text_color = RATING_MODERATE_TEXT_COLOR
	else:
		tint_color = RATING_DANGER_COLOR
		text_color = RATING_DANGER_TEXT_COLOR
	rich_text_label.text = str("[color=", Util.get_color_hex(text_color), "]", rating.value, "/", rating.max_value, "[/color]")
	gui_bordered_progress_bar.tint_progress = tint_color

func _play_animation(diff:int) -> void:
	var popup:PopupLabel = POPUP_LABEL_SCENE.instantiate()
	add_child(popup)
	popup.global_position = Util.get_control_global_position(self, gui_bordered_progress_bar) + Vector2.RIGHT * gui_bordered_progress_bar.size.x
	var color:Color
	if diff > 0:
		color = RATING_SAFE_COLOR
	elif diff < 0:
		color = RATING_DANGER_COLOR
	await popup.animate_show_label_and_destroy(str(diff), -10, 10, POPUP_SHOW_TIME, POPUP_DESTROY_TIME, color)
