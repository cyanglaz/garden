class_name WeatherManager
extends RefCounted

#var week:int
var weathers:Array[WeatherData]

func generate_weathers(number_of_weathers:int, week:int) -> void:
	weathers = MainDatabase.weather_database.roll_weathers(number_of_weathers, week)

func get_current_weather(day:int) -> WeatherData:
	return weathers[day - 1]

func get_forecasts(day:int) -> Array[WeatherData]:
	if day == weathers.size():
		return []
	return weathers.slice(day + 1)

func apply_weather_actions(day:int, fields:Array[Field]) -> void:
	var weather_data:WeatherData = get_current_weather(day)
	for field:Field in fields:
		field.apply_weather_actions(weather_data)
