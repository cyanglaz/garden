class_name Mist
extends WeatherAbilityAnimation

const ANIMATION_TIME := 0.6
const FOG_TIME := 1.5

@onready var fog_particle: GPUParticles2D = %FogParticle

func start(_icon_position:Vector2, target_position:Vector2, _is_blocked:bool) -> void:
	global_position = target_position
	fog_particle.emitting = true
	
	await Util.create_scaled_timer(ANIMATION_TIME).timeout
	
	Util.create_scaled_timer(FOG_TIME).timeout.connect(func() -> void:
		fog_particle.emitting = false
	)
