class_name WeatherData
extends ThingData


@export var abilities:Array[WeatherAbilityData]
@export var sky_color:Color

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_weather: WeatherData = other as WeatherData
	abilities = other_weather.abilities.duplicate()
	sky_color = other_weather.sky_color

func get_duplicate() -> WeatherData:
	var dup:WeatherData = WeatherData.new()
	dup.copy(self)
	return dup
