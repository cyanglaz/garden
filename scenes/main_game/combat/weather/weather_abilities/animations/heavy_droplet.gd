class_name HeavyDroplet
extends WeatherAbilityAnimation

const DROP_STARTING_Y := -70
const DROP_STARTING_SCALE := 0.3
const DROP_DURATION := 0.6

@onready var drop: Sprite2D = %Drop
@onready var water_droplet_emitter: WaterDropletEmitter = %WaterDropletEmitter

func _ready() -> void:
	drop.position.y = DROP_STARTING_Y
	drop.scale = Vector2.ONE * DROP_STARTING_SCALE

func start(target_position:Vector2, _is_blocked:bool) -> void:
	global_position = target_position

	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	tween.tween_property(drop, "position:y", 0.0, DROP_DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(drop, "scale", Vector2.ONE, DROP_DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(drop.hide).set_delay(DROP_DURATION)
	await tween.finished
	water_droplet_emitter.emit_droplets()
