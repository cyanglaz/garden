class_name GUIFieldSelectionArrow
extends Control

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func activate() -> void:
	animation_player.play("active")

func deactivate() -> void:
	animation_player.play("RESET")
