class_name WeatherAbilityGeneratorCloudy
extends WeatherAbilityGenerator

const GLOOM_ABILITY := preload("res://data/weather_abilities/weather_abilitiy_gloom.tres")

var _gloom_ability_level:int = -1
var _gloom_counter := 1

#region for override
func _generate_abilities(combat_main:CombatMain, _turn_index:int) -> Array[WeatherAbility]:
	var fields_have_abilities:Array
	var field_indices := range(combat_main.plant_field_container.plants.size())
	var ability_datas:Array[WeatherAbilityData]
	for i in _gloom_counter:
		ability_datas.append(GLOOM_ABILITY.get_duplicate())
	_gloom_counter += 1
	if _gloom_counter >= combat_main.plant_field_container.plants.size():
		_gloom_counter = 1
		_gloom_ability_level += 1
	fields_have_abilities = field_indices.slice(0, ability_datas.size()).duplicate()
	var abilities:Array[WeatherAbility] = _instantiate_abilities(ability_datas)
	for ability:WeatherAbility in abilities:
		ability.field_index = fields_have_abilities.pop_back()
	return abilities

#endregion
