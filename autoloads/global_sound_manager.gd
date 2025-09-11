extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_sound(steam:AudioStream, bus:String = "SFX",  volume_db:float = 0.0, finished_callback:Callable = Callable()) -> void:
	var audio_stream_player_2d: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio_stream_player_2d.stream = steam
	audio_stream_player_2d.bus = bus
	audio_stream_player_2d.volume_db = volume_db
	add_child(audio_stream_player_2d)
	audio_stream_player_2d.play()
	await audio_stream_player_2d.finished
	if finished_callback:
		finished_callback.call()
	audio_stream_player_2d.queue_free()
