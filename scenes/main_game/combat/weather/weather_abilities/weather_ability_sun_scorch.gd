class_name WeatherAbilitySunScorch
extends WeatherAbility

@onready var sun_scorch: SunScorch = %SunScorch

func _run_animation(target_position:Vector2, blocked_by_player:bool) -> void:
	await sun_scorch.execute_scorch(target_position, blocked_by_player)
