class_name SlowMotionHandle
extends Node

@onready var timer: Timer = %Timer

func _ready() -> void:
	Events.request_slow_motion.connect(_on_request_slow_motion)
	timer.timeout.connect(_on_timer_timeout)

func _on_request_slow_motion(scale:float, time:float):
	if !timer.is_stopped():
		timer.stop()
	Engine.time_scale = scale
	timer.wait_time = time
	AudioServer.playback_speed_scale = scale
	timer.start()
	
func _on_timer_timeout():
	Engine.time_scale = 1.0
	AudioServer.playback_speed_scale = 1.0
