class_name WeatherAbilityGenerator
extends RefCounted

const WEATHER_ABILITIES_SCENE_PREFIX := "res://scenes/main_game/combat/weather/weather_abilities/abilities/weather_ability_%s.tscn"

var weather_data:WeatherData
var combat_type:CombatData.CombatType = CombatData.CombatType.COMMON

func setup_with_weather_data(data:WeatherData, ct:CombatData.CombatType) -> void:
	weather_data = data
	combat_type = ct

func generate_abilities(combat_main:CombatMain, turn_index:int) -> Array[WeatherAbility]:
	return _generate_abilities(combat_main, turn_index)

#region for override
func _generate_abilities(_combat_main:CombatMain, _turn_index:int) -> Array[WeatherAbility]:
	return []

#endregion

#region private functions

func _generate_ability(ability_data:WeatherAbilityData) -> WeatherAbility:
	var weather_ability_scene:PackedScene = load(WEATHER_ABILITIES_SCENE_PREFIX % ability_data.id)
	var weather_ability:WeatherAbility = weather_ability_scene.instantiate()
	weather_ability.setup_with_weather_ability_data(ability_data)
	return weather_ability

#endregion

func _instantiate_abilities(ability_datas:Array[WeatherAbilityData]) -> Array[WeatherAbility]:
	var abilities:Array[WeatherAbility] = []
	for i in ability_datas.size():
		var ability:WeatherAbilityData = ability_datas[i]
		var weather_ability:WeatherAbility = _generate_ability(ability)
		weather_ability.setup_with_weather_ability_data(ability)
		abilities.append(weather_ability)
	return abilities
