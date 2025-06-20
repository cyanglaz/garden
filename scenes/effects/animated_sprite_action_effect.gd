class_name AnimatedSpriteActionEffect
extends Node2D

signal deploy_finished()

@export var auto_destroy := false

@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _audio: AudioStreamPlayer2D = %Audio

var _animation_finished:bool = false
var _audio_finished:bool = false

func _ready() -> void:
	_audio.finished.connect(_on_audio_finished)
	_animation_player.animation_finished.connect(_on_animation_finished)
	_animation_player.play("start")
	_audio.play()

func _try_destroy() -> void:
	if _audio_finished && _animation_finished:
		deploy_finished.emit()
		if auto_destroy:
			queue_free()

func _on_audio_finished() -> void:
	_audio_finished = true
	_try_destroy()
	
func _on_animation_finished(_name:String) -> void:
	_animation_finished = true
	_try_destroy()
