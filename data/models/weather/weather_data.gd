class_name WeatherData
extends ThingData

@export var actions:Array[ActionData]

func copy(other:ThingData) -> void:
	var other_weather: WeatherData = other as WeatherData
	actions = other_weather.actions.duplicate()

func get_duplicate() -> WeatherData:
	var dup:WeatherData = WeatherData.new()
	dup.copy(self)
	return dup

func get_display_description() -> String:
	var formatted_description := description
	formatted_description = _formate_references(formatted_description, data, func(_reference_id:String) -> bool:
		return false
	)
	return formatted_description
