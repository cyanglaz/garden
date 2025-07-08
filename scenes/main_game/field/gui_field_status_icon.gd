class_name GUIFieldStatusIcon
extends PanelContainer

const ANIMATION_OFFSET := 3

@onready var _icon: TextureRect = %Icon
@onready var _stack: Label = %Stack
@onready var _good_animation_audio: AudioStreamPlayer2D = %GoodAnimationAudio
@onready var _bad_animation_audio: AudioStreamPlayer2D = %BadAnimationAudio

var status_id:String = ""
var status_type:FieldStatusData.Type

func setup_with_field_status_data(field_status_data:FieldStatusData) -> void:
	_icon.texture = load(Util.get_image_path_for_resource_id(field_status_data.id))
	_stack.text = str(field_status_data.stack)
	status_id = field_status_data.id
	status_type = field_status_data.type

func play_trigger_animation() -> void:
	match status_type:
		FieldStatusData.Type.BAD:
			_bad_animation_audio.play()
		FieldStatusData.Type.GOOD:
			_good_animation_audio.play()
	var original_position:Vector2 = _icon.position
	var tween:Tween = Util.create_scaled_tween(self)
	for i in 2:
		tween.tween_property(_icon, "position", _icon.position + Vector2.UP * ANIMATION_OFFSET, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(_icon, "position", original_position, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
