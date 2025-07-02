class_name GUIWeatherContainer
extends VBoxContainer

const FORCAST_SIZE_SCALE := 0.7

const GUI_WEATHER_SCENE := preload("res://scenes/GUI/main_game/weather/gui_weather.tscn")

@onready var _today_weather_icon: GUIWeather = %TodayWeatherIcon
@onready var _forcast_container: VBoxContainer = %ForcastContainer

func update_with_weather_manager(weather_manager:WeatherManager, day:int) -> void:
	Util.remove_all_children(_forcast_container)
	var today_weather := weather_manager.get_current_weather(day)
	_today_weather_icon.setup_with_weather_data(today_weather)
	var forcasts := weather_manager.get_forcasts(day)
	for weather_data:WeatherData in forcasts:
		var gui_weather := GUI_WEATHER_SCENE.instantiate()
		gui_weather.custom_minimum_size *= FORCAST_SIZE_SCALE
		_forcast_container.add_child(gui_weather)
		gui_weather.setup_with_weather_data(weather_data)
