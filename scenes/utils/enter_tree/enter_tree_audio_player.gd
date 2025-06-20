class_name EnterTreeAudioPlayer
extends AudioStreamPlayer

@export var loop := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if loop && !finished.is_connected(_on_sound_finished):
		finished.connect(_on_sound_finished)
	play()
	
func _enter_tree() -> void:
	if is_node_ready():
		play()
		
func _exit_tree() -> void:
	stop()

func _on_sound_finished():
	assert(loop)
	play()
