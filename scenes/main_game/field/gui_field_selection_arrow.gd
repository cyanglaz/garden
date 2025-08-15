class_name GUIFieldSelectionArrow
extends Control

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var line: TextureRect = %Line

var is_active:bool:set= _set_is_active

func _set_is_active(value:bool) -> void:
	is_active = value
	if is_active:
		animation_player.play("active")
	else:
		animation_player.play("RESET")
