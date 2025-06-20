class_name GUIActionPoints
extends HBoxContainer

@onready var _label: Label = %Label
@onready var _texture_rect: TextureRect = %TextureRect
@onready var _ap_increased_sound: AudioStreamPlayer2D = %APIncreasedSound
@onready var _ap_decreased_sound: AudioStreamPlayer2D = %APDecreasedSound

var _current_ap:int = 0

func set_static_ap(ap:int) -> void:
	_label.text = str(ap)

func animate_update_ap(ap:int) -> void:
	# Animate texture 
	var tween:Tween = Util.create_scaled_tween(self)
	_label.pivot_offset = _label.size/2
	_texture_rect.pivot_offset = _texture_rect.size/2
	# Add a slight pause because the animation
	tween.set_parallel(true)
	# Simulate 3D rotation by scaling x to create perspective
	tween.tween_property(_texture_rect, "scale:x", -1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(_texture_rect, "scale:x", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.1)
	var delay := 0.0
	print_debug("ap: %s, _current_ap: %s"%[ap, _current_ap])
	var ap_diff:int = ap - _current_ap
	if ap_diff < 0:
		_ap_decreased_sound.play()
		tween.tween_property(_label, "text", str(ap), 0.2)
	else:
		for i in range(_current_ap + 1, ap + 1):
			var animation_time := 0.1
			Util.create_scaled_timer(delay).timeout.connect(_ap_increased_sound.play)
			Util.create_scaled_timer(delay + animation_time).timeout.connect(func(): _label.text = str(i))
			tween.tween_property(_label, "scale", Vector2.ONE * 1.5, animation_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(delay)
			tween.tween_property(_label, "scale", Vector2.ONE, animation_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(delay + animation_time)
			delay += animation_time * 2
	tween.set_parallel(false)
	# Add a slight pause after the animation
	tween.tween_interval(0.5)
	await tween.finished
	_current_ap = ap
	set_static_ap(_current_ap)
