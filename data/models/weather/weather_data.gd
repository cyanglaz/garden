class_name WeatherData
extends ThingData


@export var actions:Array[ActionData]
@export var sky_color:Color

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_weather: WeatherData = other as WeatherData
	actions = other_weather.actions.duplicate()
	sky_color = other_weather.sky_color

func get_duplicate() -> WeatherData:
	var dup:WeatherData = WeatherData.new()
	dup.copy(self)
	return dup
