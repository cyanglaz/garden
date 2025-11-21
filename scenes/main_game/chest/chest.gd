class_name Chest
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var confetti_emitter: GPUParticles2D = %ConfettiEmitter
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

var highlighted := false: set = _set_highlighted

func _ready() -> void:
	confetti_emitter.emitting = false
	confetti_emitter.one_shot = true

func open() -> void:
	animated_sprite_2d.play("open")
	confetti_emitter.restart()
	audio_stream_player_2d.play()

func _set_highlighted(val:bool) -> void:
	highlighted = val
	if highlighted:
		animated_sprite_2d.material.set_shader_parameter("outline_size", 1)
	else:
		animated_sprite_2d.material.set_shader_parameter("outline_size", 0)
