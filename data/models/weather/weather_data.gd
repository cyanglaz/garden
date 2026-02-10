class_name WeatherData
extends ThingData

@export var sky_color:Color
@export var boss:bool

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_weather: WeatherData = other as WeatherData
	sky_color = other_weather.sky_color
	boss = other_weather.boss

func get_duplicate() -> WeatherData:
	var dup:WeatherData = WeatherData.new()
	dup.copy(self)
	return dup
