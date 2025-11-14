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
	audio_stream_player_2d.volume_db = -10
	tween.tween_property(audio_stream_player_2d, "volume_db", initial_volume_db, SOUND_FADE_TIME).set_trans(Tween.TRANS_LINEAR)
	emitting = true

func stop() -> void:
	await fade_out_sounds()
	emitting = false

func fade_out_sounds() -> void:
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(audio_stream_player_2d, "volume_db", -10, SOUND_FADE_TIME).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	audio_stream_player_2d.stop()
