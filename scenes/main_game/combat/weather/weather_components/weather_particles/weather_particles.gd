class_name WeatherParticles
extends GPUParticles2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

func _ready() -> void:
	emitting = true

func start() -> void:
	audio_stream_player_2d.play()
	emitting = true

func stop() -> void:
	audio_stream_player_2d.stop()
	emitting = false
