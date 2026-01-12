class_name WeatherAbilityGeneratorSunny
extends WeatherAbilityGenerator

const SOLAR_BEAM_ABILITY := preload("res://data/weather_abilities/weather_ability_solar_beam.tres")
const SUN_SCORCH_ABILITY := preload("res://data/weather_abilities/weather_ability_sun_scorch.tres")

# Ability summon logic
const SPECIAL_TURN_THRESHOLD := 3

var _special_turn_counter:int = 0
var _special_ability_level:int = 0

#region for override
func _generate_abilities(combat_main:CombatMain, _turn_index:int) -> Array[WeatherAbility]:
	var abilities:Array[WeatherAbility] = []
	var field_indices := range(combat_main.plant_field_container.plants.size())
	var fields_have_abilities:Array
	var ability_datas:Array[WeatherAbilityData]
	print("Special turn counter: ", _special_turn_counter)
	# It's a all special ability turn
	if _special_turn_counter >= SPECIAL_TURN_THRESHOLD:
		# For special turns, we always have all sun scorch abilities
		for i in combat_main.plant_field_container.plants.size():
			ability_datas.append(SUN_SCORCH_ABILITY.get_duplicate())
			fields_have_abilities = field_indices
		_special_turn_counter = 0
		_special_ability_level += 1
	else:
		# For regular turns, we always have one solar beam and one sun scorch
		ability_datas.append(SOLAR_BEAM_ABILITY.get_duplicate())
		ability_datas.append(SUN_SCORCH_ABILITY.get_duplicate())
		ability_datas.shuffle()
		fields_have_abilities = Util.unweighted_roll(field_indices, 2)
		_special_turn_counter += 1
	
	for i in fields_have_abilities.size():
		var ability:WeatherAbilityData = ability_datas[i]
		var is_special_ability:bool = ability in weather_data.special_abilities
		var field_index:int = fields_have_abilities[i]
		var weather_ability:WeatherAbility = _generate_ability(ability)
		if is_special_ability:
			weather_ability.level = _special_ability_level
		weather_ability.field_index = field_index
		weather_ability.setup_with_weather_ability_data(ability)
		abilities.append(weather_ability)
	return abilities

#endregion
