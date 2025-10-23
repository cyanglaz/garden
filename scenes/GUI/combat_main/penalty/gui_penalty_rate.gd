class_name GUILevelTitle
extends HBoxContainer

@onready var _penalty_rate_title_label: Label = %PenaltyRateTitleLabel
@onready var _penalty_rate_value_label: Label = %PenaltyRateValueLabel

var _current_penalty := 0

func _ready() -> void:
	_penalty_rate_title_label.text = Util.get_localized_string("PENALTY_RATE_TITLE")

func update_penalty(penalty:int) -> void:
	var tween := Util.create_scaled_tween(self)
	tween.set_parallel(true)
	var has_animation := false

	var penalty_per_day_color:Color
	var penalty_per_day_string := "0"
	if penalty > 0:
		penalty_per_day_string = str(penalty)
		penalty_per_day_color = Constants.COLOR_RED
	else:
		penalty_per_day_color = Constants.COLOR_WHITE
	_penalty_rate_value_label.self_modulate = penalty_per_day_color
	_penalty_rate_value_label.text = penalty_per_day_string
	_penalty_rate_value_label.pivot_offset = _penalty_rate_value_label.size/2
	if _current_penalty != penalty:
		has_animation = true
		tween.tween_property(_penalty_rate_value_label, "scale", Vector2.ONE * 1.5, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(_penalty_rate_value_label, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(0.2)
		_current_penalty = penalty
	if has_animation:
		await tween.finished
	else:
		tween.kill()
