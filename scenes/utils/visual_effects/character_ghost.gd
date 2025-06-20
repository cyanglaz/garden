class_name CharacterGhost
extends Node2D

signal finished()

@onready var _character_ghost: AnimatedSprite2D = %CharacterGhost
@onready var _audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var _animation_player: AnimationPlayer = %AnimationPlayer

var flip_h: bool = false

var _audio_finished: bool = false
var _animation_finished: bool = false

func _ready() -> void:
	_character_ghost.flip_h = flip_h
	_character_ghost.play("loop")
	if _audio_stream_player_2d.stream:
		_audio_stream_player_2d.finished.connect(_on_audio_finished)
		_audio_stream_player_2d.play()
	else:
		_audio_finished = true
	_animation_player.play("ghost_fade_out")
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(_character_ghost, "position:y", -50, _animation_player.current_animation_length).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.play()
	await tween.finished
	_animation_finished = true
	_try_finish()

func _try_finish() -> void:
	if _audio_finished && _animation_finished:
		finished.emit()
		queue_free()

func _on_audio_finished() -> void:
	_audio_finished = true
	_try_finish()
