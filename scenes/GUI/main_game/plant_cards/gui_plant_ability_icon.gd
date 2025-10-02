class_name GUIPlantAbilityIcon
extends GUIIcon

const ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_"

const ANIMATION_OFFSET := 3

@onready var _good_animation_audio: AudioStreamPlayer2D = %GoodAnimationAudio

var ability_id:String

func update_with_plant_ability_id(plant_ability_id:String) -> void:
	ability_id = plant_ability_id
	texture = load(ICON_PATH + plant_ability_id + ".png")

func play_trigger_animation() -> void:
	_good_animation_audio.play()
	var original_position:Vector2 = position
	var tween:Tween = Util.create_scaled_tween(self)
	for i in 2:
		tween.tween_property(self, "position", position + Vector2.UP * ANIMATION_OFFSET, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position", original_position, Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION/4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
