class_name WeatherParticles
extends GPUParticles2D

const SOUND_FADE_TIME := 0.5

@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

func _ready() -> void:
	emitting = false

func start() -> void:
	audio_stream_player_2d.play()
	var tween := Util.create_scaled_tween(self)
	var initial_volume_db := audio_stream_player_2d.volume_db
	audio_stream_player_2d.volume_db = -80.0
	tween.tween_property(audio_stream_player_2d, "volume_db", initial_volume_db, SOUND_FADE_TIME).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	emitting = true

func stop() -> void:
	audio_stream_player_2d.stop()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(audio_stream_player_2d, "volume_db", -80, SOUND_FADE_TIME).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	emitting = false
