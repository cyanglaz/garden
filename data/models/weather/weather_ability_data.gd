class_name WeatherAbilityData
extends ThingData

@export var plant_actions:Array[ActionData]
@export var player_actions:Array[ActionData]

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_weather_ability_data := other as WeatherAbilityData
	plant_actions = other_weather_ability_data.plant_actions.duplicate()
	player_actions = other_weather_ability_data.player_actions.duplicate()

func get_duplicate() -> WeatherAbilityData:
	var dup:WeatherAbilityData = WeatherAbilityData.new()
	dup.copy(self)
	return dup
