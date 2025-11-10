class_name WeatherMain
extends Node2D

const WEATHER_CONTAINER_SCENE_PREFIX := "res://scenes/main_game/combat/weather/weathers/weather_%s.tscn"

signal weathers_updated()

@onready var weather_cnontainer: Node2D = %WeatherCnontainer

var weather_manager:WeatherManager = WeatherManager.new()

var _current_weather:Weather

func apply_weather_actions(plants:Array[Plant], combat_main:CombatMain) -> void:
	await weather_manager.apply_weather_actions(plants, combat_main)

func pass_day() -> void:
	weather_manager.pass_day()
	_update_weather_scene()
	weathers_updated.emit()

func generate_next_weathers(chapter:int) -> void:
	weather_manager.generate_next_weathers(chapter)
	_update_weather_scene()

func get_current_weather() -> WeatherData:
	return weather_manager.get_current_weather()

func _update_weather_scene() -> void:
	if _current_weather:
		_current_weather.queue_free()
	var current_weather_id := weather_manager.get_current_weather().id
	var new_weather_container_scene := load(str(WEATHER_CONTAINER_SCENE_PREFIX % current_weather_id))
	_current_weather = new_weather_container_scene.instantiate()
	weather_cnontainer.add_child(_current_weather)
	weathers_updated.emit()
