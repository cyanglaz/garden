class_name EnterTreeAnimationPlayer
extends AnimationPlayer

@export var animation:String
@export var auto_play:bool : set = _set_auto_play

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if auto_play:
		play(animation)

func _enter_tree() -> void:
	if is_node_ready() && auto_play:
		play(animation)

func _set_auto_play(val:bool):
	auto_play = val
	if !is_playing() && auto_play:
		play(animation)
	
