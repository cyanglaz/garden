class_name SporeDrift
extends WeatherAbilityAnimation

const TOTAL_TIME := 1.0

@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

func start(_icon_position:Vector2, target_position:Vector2, _is_blocked:bool) -> void:
	global_position = target_position
	audio_stream_player_2d.play()

	gpu_particles_2d.emitting = true

	await Util.create_scaled_timer(TOTAL_TIME).timeout
	gpu_particles_2d.emitting = false
