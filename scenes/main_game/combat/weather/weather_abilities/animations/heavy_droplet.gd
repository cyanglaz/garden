class_name HeavyDroplet
extends WeatherAbilityAnimation

const WATER_DROP_SPRITE_SCENE := preload("res://scenes/main_game/combat/weather/weather_abilities/animations/water_drop_sprite.tscn")


const DROP_STARTING_Y := -70
const DROP_STARTING_SCALE := 0.3
const DROP_DURATION := 0.6
const DROP_DELAY := 0.1
const DROP_SPREAD := 10.0

@export var number_of_droplets := 1

@onready var water_droplet_emitter: WaterDropletEmitter = %WaterDropletEmitter
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

func start(_icon_position:Vector2, target_position:Vector2, _is_blocked:bool) -> void:
	global_position = target_position
	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for i in number_of_droplets:
		var water_drop_sprite := WATER_DROP_SPRITE_SCENE.instantiate()
		if i != 0:
			water_drop_sprite.position.x = randf_range(-DROP_SPREAD, DROP_SPREAD)
		add_child(water_drop_sprite)
		water_drop_sprite.hide()
		water_drop_sprite.position.y = DROP_STARTING_Y
		water_drop_sprite.scale = Vector2.ONE * DROP_STARTING_SCALE
		tween.tween_callback(water_drop_sprite.show).set_delay(DROP_DELAY * i)
		tween.tween_property(water_drop_sprite, "position:y", 0.0, DROP_DURATION).set_delay(DROP_DELAY * i).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(water_drop_sprite, "scale", Vector2.ONE, DROP_DURATION).set_delay(DROP_DELAY * i).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(water_drop_sprite.hide).set_delay(DROP_DELAY * i + DROP_DURATION)
		tween.tween_callback(audio_stream_player_2d.play).set_delay(DROP_DELAY * i)
		tween.tween_callback(water_droplet_emitter.emit_droplets).set_delay(DROP_DELAY * i + DROP_DURATION)
	await tween.finished
