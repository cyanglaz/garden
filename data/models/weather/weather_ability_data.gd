class_name WeatherAbilityData
extends ThingData

@export var action_datas:Array[ActionData]

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_weather_ability_data := other as WeatherAbilityData
	action_datas = other_weather_ability_data.action_datas.duplicate()

func get_duplicate() -> WeatherAbilityData:
	var dup:WeatherAbilityData = WeatherAbilityData.new()
	dup.copy(self)
	return dup
