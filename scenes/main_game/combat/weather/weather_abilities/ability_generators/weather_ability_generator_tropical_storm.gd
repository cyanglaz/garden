class_name WeatherAbilityGeneratorTropicalStorm
extends WeatherAbilityGenerator

const GALE_DEBRIS_ABILITY := preload("res://data/weather_abilities/weather_ability_gale_debris.tres")
const LIGHTNING_STRIKE_ABILITY := preload("res://data/weather_abilities/weather_ability_lightning_strike.tres")

const LIGHTNING_STRIKE_CHANCE := 0.7

#region for override
func _generate_abilities(combat_main:CombatMain, _turn_index:int) -> Array[WeatherAbility]:
	var abilities:Array[WeatherAbility] = []
	var field_indices := range(combat_main.plant_field_container.plants.size())
	field_indices.shuffle()
	var is_lightning_strike:bool = randf() < LIGHTNING_STRIKE_CHANCE
	var ability_datas:Array[WeatherAbilityData] = []
	if is_lightning_strike:
		for i in field_indices.size() - 1:
			ability_datas.append(LIGHTNING_STRIKE_ABILITY.get_duplicate())
	else:
		for i in field_indices.size() - 2:
			ability_datas.append(GALE_DEBRIS_ABILITY.get_duplicate())

	var fields_have_abilities:Array = field_indices.slice(0, ability_datas.size()).duplicate()
	abilities = _instantiate_abilities(ability_datas)
	for ability:WeatherAbility in abilities:
		ability.field_index = fields_have_abilities.pop_front()
	return abilities


#endregion
