class_name WeatherManager
extends RefCounted

signal weathers_updated()
signal all_weather_actions_applied()

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

func apply_weather_actions(combat_main:CombatMain) -> void:
	await _apply_weather_action_to_next_plant(combat_main)

func _apply_weather_action_to_next_plant(combat_main:CombatMain) -> void:
	var plant_index:int = combat_main.player.current_field_index
	var plant:Plant = combat_main.get_current_player_plant()
	if plant_index < 0:
		all_weather_actions_applied.emit()
		return
	var today_weather:WeatherData = get_current_weather()
	if !_should_weather_be_applied(today_weather, plant):
		await _apply_weather_action_to_next_plant(combat_main)
	else:
		await combat_main.gui.gui_weather_container.animate_weather_application(today_weather, plant)
		await plant.apply_weather_actions(today_weather)
		await _apply_weather_action_to_next_plant(combat_main)

func _should_weather_be_applied(weather_data:WeatherData, plant:Plant) -> bool:
	if weather_data.actions.is_empty():
		return false
	if plant.is_bloom():
		return false
	for action:ActionData in weather_data.actions:
		return true
	return false
