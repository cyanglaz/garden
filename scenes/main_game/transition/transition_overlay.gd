class_name TransitionOverlay
extends Control

enum Type {
	FADE_IN,
	FADE_OUT,
}

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func transition(type:Type, duration:float = 1.0) -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var transition_name:String
	match type:
		Type.FADE_IN:
			transition_name = "fade_in"
		Type.FADE_OUT:
			transition_name = "fade_out"
	animation_player.play(transition_name, -1.0, 1.0/duration)
	await animation_player.animation_finished
	mouse_filter = Control.MOUSE_FILTER_IGNORE
