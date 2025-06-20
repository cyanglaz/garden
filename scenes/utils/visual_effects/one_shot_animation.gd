class_name OneShotAnimation
extends AnimatedSprite2D

@export var signal_frame := -1

@onready var _audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

var _sound_finished := false
var _animation_finished := false

signal done()

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	if signal_frame > 0:
		frame_changed.connect(_on_frame_changed)
	_audio_stream_player_2d.finished.connect(_on_sound_finished)
	play("deploy")
	_audio_stream_player_2d.play()

func _try_free() -> void:
	if _animation_finished && _sound_finished:
		if signal_frame == -1:
			done.emit()
		queue_free()

func _on_animation_finished() -> void:
	_animation_finished = true
	hide()
	_try_free()

func _on_sound_finished() -> void:
	_sound_finished = true
	_try_free()

func _on_frame_changed() -> void:
	if frame == signal_frame:
		done.emit()
