class_name GUITrinketButton
extends GUIBasicButton

@onready var _texture_rect: NinePatchRect = %NinePatchRect
@onready var _collected_sound: AudioStreamPlayer2D = %CollectedSound

func _ready() -> void:
	super._ready()
	_texture_rect.pivot_offset_ratio = Vector2.ONE * 0.5

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !_texture_rect:
		return
	match button_state:
		ButtonState.NORMAL:
			_texture_rect.region_rect.position = Vector2(0, 0)
		ButtonState.PRESSED:
			_texture_rect.region_rect.position = Vector2(12, 0)
		ButtonState.HOVERED:
			_texture_rect.region_rect.position = Vector2(24, 0)
		ButtonState.DISABLED:
			_texture_rect.region_rect.position = Vector2(0, 12)
		ButtonState.SELECTED:
			_texture_rect.region_rect.position = Vector2(24, 12)		

func play_collected_animation() -> void:
	_collected_sound.play()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_texture_rect, "scale", Vector2.ONE * 1.5, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_texture_rect, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
