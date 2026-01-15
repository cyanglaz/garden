class_name Gloom
extends WeatherAbilityAnimation

const TOTAL_TIME := 1.0
const APPEAR_TIME := 0.2
const DISAPPEAR_TIME := 0.2
const SHADOW_INITIAL_SCALE := Vector2(0.5, 0.5)

@onready var cloud_shadow: Sprite2D = %CloudShadow
@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D

func start(_icon_position:Vector2, target_position:Vector2, _is_blocked:bool) -> void:

	global_position = target_position
	
	cloud_shadow.scale = Vector2.ONE * SHADOW_INITIAL_SCALE # Start big and diffuse
	
	Util.create_scaled_timer(APPEAR_TIME).timeout.connect(gpu_particles_2d.restart)

	var tween = create_tween()
	tween.tween_property(cloud_shadow, "scale", Vector2.ONE, APPEAR_TIME)
	tween.tween_property(cloud_shadow, "scale", Vector2.ZERO, DISAPPEAR_TIME).set_delay(TOTAL_TIME)
	await Util.create_scaled_timer(TOTAL_TIME).timeout
	gpu_particles_2d.emitting = false
	tween.finished.connect(hide)
