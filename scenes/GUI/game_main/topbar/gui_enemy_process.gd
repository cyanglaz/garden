class_name GUIEnemyProcess
extends HBoxContainer

# @onready var _texture_rect: TextureRect = %TextureRect
@onready var _label: Label = %Label

var _draws_left:int = 0
var _weak_tool_tip:WeakRef = weakref(null)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_draws_left(draws_left:int) -> void:
	_draws_left = draws_left
	_label.text = str(draws_left)

func animate_update_draws_left(new_value:int) -> void:
	var draws_left_diff:int = new_value - _draws_left
	if draws_left_diff == 0:
		return
	# Animate texture 
	# Add a slight pause because the animation
	# Simulate 3D rotation by scaling x to create perspective
	if draws_left_diff < 0:
		_label.pivot_offset = _label.size/2
		var delay := 0.0
		var tween:Tween = Util.create_scaled_tween(self)
		tween.set_parallel(true)
		var target_scale := 1.5
		if new_value <= 2:
			target_scale = 2.0
		for i in range(_draws_left-1, new_value-1, -1):
			var animation_time := 0.1
			Util.create_scaled_timer(delay + animation_time).timeout.connect(func(): _label.text = str(i))
			tween.tween_property(_label, "scale", Vector2.ONE * target_scale, animation_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(delay)
			tween.tween_property(_label, "scale", Vector2.ONE, animation_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(delay + animation_time)
			delay += animation_time * 2
		await tween.finished
		set_draws_left(new_value)

func _on_mouse_entered() -> void:
	var draw_text := Util.convert_to_bbc_highlight_text(str(_draws_left), Constants.TOOLTIP_HIGHLIGHT_COLOR_PURPLE)
	_weak_tool_tip = weakref(Util.display_rich_text_tooltip(str(draw_text, " draws left before next enemy joining the battle."), self, false,  GUITooltip.TooltipPosition.BOTTOM))

func _on_mouse_exited() -> void:
	_weak_tool_tip.get_ref().queue_free()
