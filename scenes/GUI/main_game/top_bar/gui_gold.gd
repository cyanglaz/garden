class_name GUIGold
extends HBoxContainer

@onready var _label: Label = %Label
@onready var _texture_rect: TextureRect = %TextureRect
@onready var _gold_increased_sound: AudioStreamPlayer2D = %GoldIncreasedSound
@onready var _gold_decreased_sound: AudioStreamPlayer2D = %GoldDecreasedSound

var _current_gold:int = 0

func update_gold(gold:int, animated:bool = true) -> void:
	if animated:
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
		print_debug("gold: %s, _current_gold: %s"%[gold, _current_gold])
		var gold_diff:int = gold - _current_gold
		if gold_diff < 0:
			_gold_decreased_sound.play()
			tween.tween_property(_label, "text", str(gold), 0.2)
		else:
			for i in range(_current_gold + 1, gold + 1):
				var animation_time := 0.1
				Util.create_scaled_timer(delay).timeout.connect(_gold_increased_sound.play)
				Util.create_scaled_timer(delay + animation_time).timeout.connect(func(): _label.text = str(i))
				tween.tween_property(_label, "scale", Vector2.ONE * 1.5, animation_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(delay)
				tween.tween_property(_label, "scale", Vector2.ONE, animation_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(delay + animation_time)
				delay += animation_time * 2
		tween.set_parallel(false)
		# Add a slight pause after the animation
		tween.tween_interval(0.5)
		await tween.finished
	_current_gold = gold
	_label.text = str(_current_gold)
