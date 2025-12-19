class_name Tavern
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D

var highlighted := false: set = _set_highlighted

func _ready() -> void:
	gpu_particles_2d.emitting = false

func _set_highlighted(val:bool) -> void:
	highlighted = val
	if highlighted:
		animated_sprite_2d.play("open")
		animated_sprite_2d.material.set_shader_parameter("outline_size", 1)
		gpu_particles_2d.emitting = true
	else:
		animated_sprite_2d.play("closed")
		animated_sprite_2d.material.set_shader_parameter("outline_size", 0)
		gpu_particles_2d.emitting = false
