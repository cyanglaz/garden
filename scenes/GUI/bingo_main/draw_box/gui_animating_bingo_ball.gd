class_name GUIAnimatingBingoBall
extends GUIBingoBall

@onready var _move_audio_player: AudioStreamPlayer2D = %MoveAudioPlayer

func play_move_sound() -> void:
	_move_audio_player.play()
