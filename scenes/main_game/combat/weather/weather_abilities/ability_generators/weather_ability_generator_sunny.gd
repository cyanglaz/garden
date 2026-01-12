class_name WeatherAbilityGeneratorSunny
extends WeatherAbilityGenerator

const SOLAR_BEAM_ABILITY := preload("res://data/weather_abilities/weather_ability_solar_beam.tres")
const SUN_SCORCH_ABILITY := preload("res://data/weather_abilities/weather_ability_sun_scorch.tres")

# Ability summon logic
const SPECIAL_TURN_THRESHOLD := 3

var _special_turn_counter:int = 0
var _sun_scorch_ability_level:int = -1

#region for override
func _generate_abilities(combat_main:CombatMain, _turn_index:int) -> Array[WeatherAbility]:
	var field_indices := range(combat_main.plant_field_container.plants.size())
	var fields_have_abilities:Array
	var ability_datas:Array[WeatherAbilityData]
	# It's a all special ability turn
	if _special_turn_counter >= SPECIAL_TURN_THRESHOLD:
		# For special turns, we always have all sun scorch abilities
		for i in combat_main.plant_field_container.plants.size():
			ability_datas.append(SUN_SCORCH_ABILITY.get_duplicate())
		fields_have_abilities = field_indices
		_special_turn_counter = 0
		_sun_scorch_ability_level += 1
	else:
		# For regular turns, we always have one solar beam and one sun scorch
		ability_datas.append(SOLAR_BEAM_ABILITY.get_duplicate())
		ability_datas.append(SUN_SCORCH_ABILITY.get_duplicate())
		ability_datas.shuffle()
		fields_have_abilities = Util.unweighted_roll(field_indices, 2)
		_special_turn_counter += 1
	
	var abilities:Array[WeatherAbility] = _instantiate_abilities(ability_datas)
	for ability:WeatherAbility in abilities:
		if ability.weather_ability_data.id == SUN_SCORCH_ABILITY.id:
			ability.level = _sun_scorch_ability_level
		ability.field_index = fields_have_abilities.pop_back()
	return abilities

#endregion
