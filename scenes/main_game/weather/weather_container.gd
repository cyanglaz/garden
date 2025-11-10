class_name WeatherContainer
extends Node2D

const WEATHER_SCENE_PATH_PREFIX := "res://scenes/main_game/weather/weathers/weather_%s.tscn"

signal weathers_updated()

var weather_manager:WeatherManager = WeatherManager.new()

var _current_weather_scene:Weather

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
	if _current_weather_scene:
		_current_weather_scene.queue_free()
	var current_weather_id := weather_manager.get_current_weather().id
	var new_weather_scene := load(str(WEATHER_SCENE_PATH_PREFIX % current_weather_id))
	_current_weather_scene = new_weather_scene.instantiate()
	add_child(_current_weather_scene)
	weathers_updated.emit()
