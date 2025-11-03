class_name GUIPenaltyRate
extends HBoxContainer

@onready var _penalty_rate_value_label: Label = %PenaltyRateValueLabel
@onready var gui_icon: GUIIcon = %GUIIcon

var _current_penalty := 0
var _tooltip_id:String = ""

func _ready() -> void:
	gui_icon.mouse_entered.connect(_on_mouse_entered)
	gui_icon.mouse_exited.connect(_on_mouse_exited)

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

func _on_mouse_entered() -> void:
	gui_icon.has_outline = true
	_tooltip_id = Util.get_uuid()
	var penalty_rate_string := Util.convert_to_bbc_highlight_text(str(_current_penalty), Constants.COLOR_RED)
	var text := DescriptionParser.format_references(Util.get_localized_string("PENALTY_RATE_DESCRIPTION") % [penalty_rate_string], {}, {}, func(_reference_id:String) -> bool: return false)
	Events.request_display_tooltip.emit(GUITooltipContainer.TooltipType.RICH_TEXT, text, _tooltip_id, self, false, GUITooltip.TooltipPosition.BOTTOM_LEFT, false)

func _on_mouse_exited() -> void:
	gui_icon.has_outline = false
	Events.request_hide_tooltip.emit(_tooltip_id)
