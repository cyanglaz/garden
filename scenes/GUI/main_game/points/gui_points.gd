class_name GUIPoints
extends HBoxContainer

@onready var icon: TextureRect = %Icon
@onready var earned_label: Label = %EarnedLabel
@onready var due_amount_label: Label = %DueAmountLabel
@onready var point_increase_sound: AudioStreamPlayer2D = %PointIncreaseSound

var _current_earned:int = 0

func update_earned(points:int) -> void:
	if points == 0:
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
	var animation_time := 0.05
	for i in range(_current_earned + 1, points + 1):
		Util.create_scaled_timer(delay).timeout.connect(point_increase_sound.play)
		Util.create_scaled_timer(delay + animation_time).timeout.connect(func(): earned_label.text = str(i))
		tween.tween_property(earned_label, "scale", Vector2.ONE * 1.5, animation_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(delay)
		tween.tween_property(earned_label, "scale", Vector2.ONE, animation_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(delay + animation_time)
		delay += animation_time * 2
	earned_label.text = str(points)
	await tween.finished

func update_due(points:int) -> void:
	due_amount_label.text = str(points)
