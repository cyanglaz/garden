class_name WeatherAbilityGeneratorCloudy
extends WeatherAbilityGenerator

const GLOOM_ABILITY := preload("res://data/weather_abilities/weather_ability_gloom.tres")
const SPORE_DRIFT_ABILITY := preload("res://data/weather_abilities/weather_ability_spore_drift.tres")

const GLOOM_TURN_THRESHOLD := 3
var _gloom_ability_level:int = -1
var _spore_drift_counter := 1

#region for override
func _generate_abilities(combat_main:CombatMain, _turn_index:int) -> Array[WeatherAbility]:
	var fields_have_abilities:Array
	var field_indices := range(combat_main.plant_field_container.plants.size())
	field_indices.shuffle()
	var ability_datas:Array[WeatherAbilityData]

	if _spore_drift_counter == GLOOM_TURN_THRESHOLD:
		for i in combat_main.plant_field_container.plants.size():
			ability_datas.append(GLOOM_ABILITY.get_duplicate())
			_spore_drift_counter = 1
		_gloom_ability_level += 1
	else:
		for i in _spore_drift_counter:
			ability_datas.append(SPORE_DRIFT_ABILITY.get_duplicate())
		_spore_drift_counter += 1
	fields_have_abilities = field_indices.slice(0, ability_datas.size()).duplicate()
	var abilities:Array[WeatherAbility] = _instantiate_abilities(ability_datas)
	for ability:WeatherAbility in abilities:
		ability.field_index = fields_have_abilities.pop_back()
		if ability.weather_ability_data.id == GLOOM_ABILITY.id:
			ability.level = _gloom_ability_level
	return abilities

#endregion
