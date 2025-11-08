class_name GUIWeatherAction
extends GUIAction

var WEATHER_DATA_SUNNY := load("res://data/weathers/weather_sunny.tres")
var WEATHER_DATA_RAINY := load("res://data/weathers/weather_rainy.tres")

@onready var gui_weather: GUIWeather = %GUIWeather

func update_with_action(action_data:ActionData, _target_plant:Plant) -> void:
	assert(action_data.action_category == ActionData.ActionCategory.WEATHER, "Action is not a weather action")
	match action_data.type:
		ActionData.ActionType.WEATHER_SUNNY:
			gui_weather.setup_with_weather_data(WEATHER_DATA_SUNNY)
		ActionData.ActionType.WEATHER_RAINY:
			gui_weather.setup_with_weather_data(WEATHER_DATA_RAINY)
		_:
			assert(false, "Invalid action type: " + str(action_data.type))
