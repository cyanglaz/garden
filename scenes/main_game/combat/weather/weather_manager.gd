class_name WeatherManager
extends RefCounted

@warning_ignore("unused_signal")
signal weathers_updated()

const WEATHER_SUNNY := preload("res://data/weathers/all_chapters/weather_sunny.tres")
const WEATHER_RAINY := preload("res://data/weathers/all_chapters/weather_tropical_storm.tres")

const WEATHER_APPLICATION_ICON_START_DELAY := 0.05

const GUI_WEATHER_SCENE := preload("res://scenes/GUI/main_game/weather/gui_weather.tscn")

var test_weather:WeatherData

#var level:int
var current_weather:WeatherData
var _chapter:int

func start(chapter:int, combat_type:CombatData.CombatType) -> void:
	_chapter = chapter
	_generate_next_weathers(_chapter, combat_type)

func _generate_next_weathers(chapter:int, combat_type:CombatData.CombatType) -> void:
	if test_weather:
		current_weather = test_weather.get_duplicate()
		return
	var available_weathers := MainDatabase.weather_database.get_weathers_by_chapter(chapter)
	available_weathers = available_weathers.filter(func(weather_data:WeatherData) -> bool:
		return weather_data.boss == (combat_type == CombatData.CombatType.BOSS)
	)
	current_weather = available_weathers.pick_random().get_duplicate()

func get_current_weather() -> WeatherData:
	return current_weather
