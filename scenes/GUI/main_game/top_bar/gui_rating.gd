class_name GUIRating
extends HBoxContainer

signal rating_update_finished(value:int)

const RATING_SAFE_COLOR := Constants.COLOR_YELLOW2
const RATING_MODERATE_COLOR := Constants.COLOR_ORANGE1
const RATING_DANGER_COLOR := Constants.COLOR_ORANGE4
const RATING_MODERATE_PERCENTAGE := 0.6
const RATING_DANGER_PERCENTAGE := 0.2

@onready var gui_bordered_progress_bar: GUIProgressBar = %GUIBorderedProgressBar
@onready var rich_text_label: RichTextLabel = %RichTextLabel

func _ready() -> void:
	gui_bordered_progress_bar.animate_set_value_finished.connect(func(value:int): rating_update_finished.emit(value))

func bind_with_rating(rating:ResourcePoint) -> void:
	rating.value_update.connect(_on_rating_value_update.bind(rating))
	rating.max_value_update.connect(_on_rating_value_update.bind(rating))
	_on_rating_value_update(rating)

func _on_rating_value_update(rating:ResourcePoint) -> void:
	gui_bordered_progress_bar.max_value = rating.max_value
	gui_bordered_progress_bar.animated_set_value(rating.value)
	var color:Color = RATING_SAFE_COLOR
	var percentage:float = (rating.value as float) / rating.max_value
	if percentage >= RATING_MODERATE_PERCENTAGE:
		color = RATING_SAFE_COLOR
	elif percentage >= RATING_DANGER_PERCENTAGE:
		color = RATING_MODERATE_COLOR
	else:
		color = RATING_DANGER_COLOR
	rich_text_label.text = str("[color=", Util.get_color_hex(color), "]", rating.value, "/", rating.max_value, "[/color]")
	gui_bordered_progress_bar.tint_progress = color
