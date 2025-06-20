class_name OneShotParticle
extends GPUParticles2D

signal done()

@onready var audio: AudioStreamPlayer2D = get_node_or_null("AudioStreamPlayer2D")

var _particle_finished := false
var _audio_finished := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	one_shot = true
	finished.connect(_on_particle_finished)
	if audio:
		audio.finished.connect(_on_audio_finished)
	_start()

func _start() -> void:
	_particle_finished = false
	if !audio:
		_audio_finished = true
	restart()

func _on_particle_finished():
	_particle_finished = true
	_queue_destroy_if_finished()
	
func _on_audio_finished():
	_audio_finished = true
	_queue_destroy_if_finished()

func _queue_destroy_if_finished():
	if _particle_finished && _audio_finished:
		done.emit()
		queue_free()
