class_name GUIFieldSelectionArrow
extends Control

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var line: TextureRect = %Line

var is_active:bool:set= _set_is_active
var is_enabled:bool:set= _set_is_enabled

func _set_is_active(value:bool) -> void:
	is_active = value
	if is_active:
		animation_player.play("active")
	else:
		animation_player.play("RESET")
	
func _set_is_enabled(value:bool) -> void:
	is_enabled = value
	if is_enabled:
		(line.texture as AtlasTexture).region.position.x = 0
	else:
		(line.texture as AtlasTexture).region.position.x = 16
