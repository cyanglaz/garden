class_name WeatherAbilityGeneratorCloudy
extends WeatherAbilityGenerator

const GLOOM_ABILITY := preload("res://data/weather_abilities/weather_ability_gloom.tres")
const SPORE_DRIFT_ABILITY := preload("res://data/weather_abilities/weather_ability_spore_drift.tres")

const GLOOM_TURN_THRESHOLD := 3
var _spore_drift_level:int = 0

#region for override
func _generate_abilities(combat_main:CombatMain, turn_index:int) -> Array[WeatherAbility]:
	var fields_have_abilities:Array
	var field_indices := range(combat_main.plant_field_container.plants.size())
	field_indices.shuffle()
	var ability_datas:Array[WeatherAbilityData]

	@warning_ignore("integer_division")
	if turn_index && turn_index%GLOOM_TURN_THRESHOLD == GLOOM_TURN_THRESHOLD - 1:
		for i in combat_main.plant_field_container.plants.size():
			ability_datas.append(GLOOM_ABILITY.get_duplicate())
		_spore_drift_level += 1
	else:
		var spore_drift_count:int = randi_range(1, combat_main.plant_field_container.plants.size())
		for i in spore_drift_count:
			ability_datas.append(SPORE_DRIFT_ABILITY.get_duplicate())
	fields_have_abilities = field_indices.slice(0, ability_datas.size()).duplicate()
	var abilities:Array[WeatherAbility] = _instantiate_abilities(ability_datas)
	for ability:WeatherAbility in abilities:
		ability.field_index = fields_have_abilities.pop_back()
		if ability.weather_ability_data.id == SPORE_DRIFT_ABILITY.id && combat_type == CombatData.CombatType.ELITE:
			ability.level = _spore_drift_level
	return abilities

#endregion
