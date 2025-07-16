class_name WeatherData
extends ThingData

@export var actions:Array[ActionData]

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_weather: WeatherData = other as WeatherData
	actions = other_weather.actions.duplicate()

func get_duplicate() -> WeatherData:
	var dup:WeatherData = WeatherData.new()
	dup.copy(self)
	return dup
