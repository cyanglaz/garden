class_name GUIWeatherContainer
extends VBoxContainer

const FORECAST_SIZE_SCALE := 0.7

const GUI_WEATHER_SCENE := preload("res://scenes/GUI/main_game/weather/gui_weather.tscn")

@onready var _today_weather_icon: GUIWeather = %TodayWeatherIcon
@onready var _forecast_container: VBoxContainer = %ForcastContainer

func update_with_weather_manager(weather_manager:WeatherManager) -> void:
	Util.remove_all_children(_forecast_container)
	var today_weather := weather_manager.get_current_weather()
	_today_weather_icon.setup_with_weather_data(today_weather)
	_today_weather_icon.has_tooltip = true
	var forecasts := weather_manager.get_forecasts()
	for weather_data:WeatherData in forecasts:
		var gui_weather := GUI_WEATHER_SCENE.instantiate()
		gui_weather.has_tooltip = true
		var gui_weather_size:float = gui_weather.custom_minimum_size.x
		var scaled_size := floori(gui_weather_size * FORECAST_SIZE_SCALE)
		gui_weather.custom_minimum_size = Vector2(scaled_size, scaled_size)
		_forecast_container.add_child(gui_weather)
		gui_weather.setup_with_weather_data(weather_data)

func get_today_weather_icon() -> GUIWeather:
	return _today_weather_icon
