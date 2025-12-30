class_name Tavern
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@onready var point_light_2d: PointLight2D = %PointLight2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

var highlighted := false: set = _set_highlighted

func _ready() -> void:
	gpu_particles_2d.emitting = false
	point_light_2d.hide()

func _physics_process(_delta: float) -> void:
	if highlighted:
		point_light_2d.energy = randf_range(1.3, 1.7)

func _set_highlighted(val:bool) -> void:
	highlighted = val
	if highlighted:
		animated_sprite_2d.play("open")
		animated_sprite_2d.material.set_shader_parameter("outline_size", 1)
		gpu_particles_2d.emitting = true
		point_light_2d.show()
		audio_stream_player_2d.play()
	else:
		animated_sprite_2d.play("closed")
		animated_sprite_2d.material.set_shader_parameter("outline_size", 0)
		gpu_particles_2d.emitting = false
		point_light_2d.hide()
		audio_stream_player_2d.stop()
