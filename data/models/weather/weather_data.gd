class_name WeatherData
extends ThingData

@export var regular_abilities:Array[WeatherAbilityData] # Abilities spawned on regular turns
@export var special_abilities:Array[WeatherAbilityData] # Abilities spawned on special turns
@export var sky_color:Color

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_weather: WeatherData = other as WeatherData
	regular_abilities = other_weather.regular_abilities.duplicate()
	special_abilities = other_weather.special_abilities.duplicate()
	sky_color = other_weather.sky_color

func get_duplicate() -> WeatherData:
	var dup:WeatherData = WeatherData.new()
	dup.copy(self)
	return dup
