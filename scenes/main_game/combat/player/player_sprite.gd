class_name PlayerSprite
extends AnimatedSprite2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func play_hurt() -> void:
	animation_player.play("hurt")
	Events.request_camera_shake_effects.emit(0.5, Vector2(20, 20), 0.2, 1.0, 0)

func play_upgrade() -> void:
	animation_player.play("upgrade")
