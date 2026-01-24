class_name GaleDebris
extends WeatherAbilityAnimation

const DEBRIS_START_OFFSET := -100
const NUMBER_OF_DEBRIS := 10
const SPREAD := 10
const DROP_DELAY := 0.05

const GALE_DEBRIS_TRASH_SCENE := preload("res://scenes/main_game/combat/weather/weather_abilities/animations/gale_debris_trash.tscn")

@onready var cluster: Node2D = %Cluster

func start(_icon_position:Vector2, target_position:Vector2, _is_blocked:bool) -> void:
	global_position = target_position
	
	for i in NUMBER_OF_DEBRIS:
		var trash := GALE_DEBRIS_TRASH_SCENE.instantiate()
		trash.global_position = Vector2(randf_range(-SPREAD, SPREAD), DEBRIS_START_OFFSET)
		cluster.add_child(trash)

	var tween:Tween = Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for i in NUMBER_OF_DEBRIS:
		var trash := cluster.get_child(i)
		tween.tween_callback(trash.fall.bind(Vector2.ZERO)).set_delay(DROP_DELAY * i)
