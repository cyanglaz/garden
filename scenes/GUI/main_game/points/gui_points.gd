class_name GUIPoints
extends HBoxContainer

const ANIMATION_TIME := 0.07

@onready var icon: TextureRect = %Icon
@onready var earned_label: Label = %EarnedLabel
@onready var due_amount_label: Label = %DueAmountLabel
@onready var point_increase_sound: AudioStreamPlayer2D = %PointIncreaseSound

var _current_earned:int = 0

func update_earned(points:int) -> void:
	if points == 0:
		_current_earned = points
		earned_label.text = str(points)
		return
	var tween:Tween = Util.create_scaled_tween(self)
	earned_label.pivot_offset = earned_label.size/2
	icon.pivot_offset = icon.size/2
	# Animate texture 
	# Add a slight pause because the animation
	tween.set_parallel(true)
	# Simulate 3D rotation by scaling x to create perspective
	tween.tween_property(icon, "scale:x", -1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(icon, "scale:x", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.1)
	assert(points - _current_earned > 0)
	var delay := 0.0
	for i in range(_current_earned + 1, points + 1):
		Util.create_scaled_timer(delay).timeout.connect(point_increase_sound.play)
		Util.create_scaled_timer(delay + ANIMATION_TIME).timeout.connect(func(): earned_label.text = str(i))
		tween.tween_property(earned_label, "scale", Vector2.ONE * 1.5, ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(delay)
		tween.tween_property(earned_label, "scale", Vector2.ONE, ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(delay + ANIMATION_TIME)
		delay += ANIMATION_TIME * 2
	_current_earned = points
	await tween.finished
	earned_label.text = str(points)

func update_due(points:int) -> void:
	due_amount_label.text = str(points)
