class_name WeatherAbilityAnimation
extends Node2D

func start(_icon_position:Vector2, _target_position:Vector2, _is_blocked:bool) -> void:
	await Util.await_for_tiny_time()
