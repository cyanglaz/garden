class_name GUIGold
extends HBoxContainer

const ANIMATION_TIME := 0.07

enum AnimationType {
	NONE,
	SINGLE,
	FULL,
}

signal gold_incremented(step:int)

@export var label_alignment:HorizontalAlignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT

@onready var _label: Label = %Label
@onready var _texture_rect: TextureRect = %TextureRect
@onready var _gold_increased_sound_single: AudioStreamPlayer2D = %GoldIncreasedSoundSingle
@onready var _gold_increased_sound_full: AudioStreamPlayer2D = %GoldIncreasedSoundFull
@onready var _gold_use_sound: AudioStreamPlayer2D = %GoldUseSound

var _current_gold:int = 0

func _ready() -> void:
	_label.horizontal_alignment = label_alignment

func update_gold(gold_diff:int, animation_type:AnimationType, increment_step:int = 1) -> void:
	var final_gold:int = _current_gold + gold_diff
	if animation_type != AnimationType.NONE:
		var tween:Tween = Util.create_scaled_tween(self)
		_label.pivot_offset = _label.size/2
		_texture_rect.pivot_offset = _texture_rect.size/2
		# Animate texture 
		# Add a slight pause because the animation
		tween.set_parallel(true)
		# Simulate 3D rotation by scaling x to create perspective
		tween.tween_property(_texture_rect, "scale:x", -1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(_texture_rect, "scale:x", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.1)
		if gold_diff < 0:
			_gold_use_sound.play()
			tween.tween_property(_label, "text", str(final_gold), 0.2)
		else:
			match animation_type:
				AnimationType.SINGLE:
					var delay := 0.0
					var i := 0
					while(_current_gold < final_gold):
						_current_gold += increment_step
						if _current_gold > final_gold:
							_current_gold = final_gold
							increment_step = gold_diff - _current_gold
						var gold_to_show := _current_gold
						Util.create_scaled_timer(delay).timeout.connect(_gold_increased_sound_single.play)
						Util.create_scaled_timer(delay).timeout.connect(func(): gold_incremented.emit(i))
						Util.create_scaled_timer(delay + ANIMATION_TIME).timeout.connect(func(): 
							_label.text = str(gold_to_show)
						)
						tween.tween_property(_label, "scale", Vector2.ONE * 1.5, ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(delay)
						tween.tween_property(_label, "scale", Vector2.ONE, ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(delay + ANIMATION_TIME)
						delay += ANIMATION_TIME * 2
						i += 1
				AnimationType.FULL:
					_gold_increased_sound_full.play()
					tween.tween_property(_label, "scale", Vector2.ONE * 1.5, ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
					tween.tween_property(_label, "scale", Vector2.ONE, ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(ANIMATION_TIME)
		await tween.finished
	_current_gold = final_gold
	_label.text = str(_current_gold)
