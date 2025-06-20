# Shader tutorial: https://www.youtube.com/watch?v=D7XSL0zBOwI&t=338s
class_name CharacterExplode
extends Node2D

signal finished()

@onready var _gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@onready var _audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

var _particle_finished: bool = false
var _audio_finished: bool = false

func _ready() -> void:
	_gpu_particles_2d.one_shot = true
	_gpu_particles_2d.emitting = false	

func play_with_sprite(sprite:Sprite2D) -> void:
	_audio_stream_player_2d.finished.connect(_on_audio_finished)
	_audio_stream_player_2d.play()
	var current_image := Util.get_current_image_from_sprite(sprite, false)
	var texture := ImageTexture.create_from_image(current_image)
	_gpu_particles_2d.process_material.set_shader_parameter("sprite",texture)
	_gpu_particles_2d.process_material.set_shader_parameter("emission_box_extends", current_image.get_used_rect().size)
	_gpu_particles_2d.emitting = true
	await _gpu_particles_2d.finished
	_particle_finished = true
	_try_finish()

func play_with_character(character:Character) -> void:
	character.character_sprite_group.sprite_animation_player.pause()
	character.character_sprite_group.character_sprite.hide()
	play_with_sprite(character.character_sprite_group.character_sprite)

func _try_finish() -> void:
	if _particle_finished && _audio_finished:
		finished.emit()
		queue_free()

func _on_audio_finished() -> void:
	_audio_finished = true
	_try_finish()
