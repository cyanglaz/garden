class_name WeatherManager
extends RefCounted

#var week:int
var weathers:Array[WeatherData]

func update_weathers(number_of_weathers:int, week:int) -> void:
	weathers = MainDatabase.weather_database.roll_weathers(number_of_weathers, week)

func get_current_weather(day:int) -> WeatherData:
	return weathers[day - 1]

func get_forcasts(day:int) -> Array[WeatherData]:
	if day == weathers.size():
		return []
	return weathers.slice(day + 1)
