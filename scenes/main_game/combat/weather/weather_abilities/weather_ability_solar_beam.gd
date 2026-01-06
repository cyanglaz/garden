class_name WeatherAbilitySolarBeam
extends WeatherAbility

@onready var solar_beam: SolarBeam = %SolarBeam

func _run_animation(target_position:Vector2, blocked_by_player:bool) -> void:
	await solar_beam.cast_beam(target_position, blocked_by_player)
