class_name PlayerSprite
extends AnimatedSprite2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func play_hurt() -> void:
	animation_player.play("hurt")
