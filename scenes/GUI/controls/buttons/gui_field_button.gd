class_name GUIFieldButton
extends GUIBasicButton

const FIELD_HOVER_SOUND := preload("res://resources/sounds/SFX/field/field_hover.wav")
const FIELD_CLICK_SOUND := preload("res://resources/sounds/SFX/field/field_click.wav")

func _get_click_sound() -> AudioStream:
	return FIELD_CLICK_SOUND

func _get_hover_sound() -> AudioStream:
	return FIELD_HOVER_SOUND
