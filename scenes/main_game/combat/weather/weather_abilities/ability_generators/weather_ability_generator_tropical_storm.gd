class_name WeatherAbilityGeneratorTropicalStorm
extends WeatherAbilityGenerator

const GALE_DEBRIS_ABILITY := preload("res://data/weather_abilities/weather_ability_gale_debris.tres")
const LIGHTNING_STRIKE_ABILITY := preload("res://data/weather_abilities/weather_ability_lightning_strike.tres")

#region for override
func _generate_abilities(combat_main:CombatMain, turn_index:int) -> Array[WeatherAbility]:
	var abilities:Array[WeatherAbility] = []
	var field_indices := range(combat_main.plant_field_container.plants.size())
	field_indices.shuffle()
	var fields_have_abilities:Array
	var ability_datas:Array[WeatherAbilityData]
	match turn_index%6:
		0:
			ability_datas.append(LIGHTNING_STRIKE_ABILITY.get_duplicate())
		1:
			ability_datas.append(GALE_DEBRIS_ABILITY.get_duplicate())
			ability_datas.append(GALE_DEBRIS_ABILITY.get_duplicate())
		2:
			for i in field_indices.size():
				ability_datas.append(GALE_DEBRIS_ABILITY.get_duplicate())
		3:
			if combat_type == CombatData.CombatType.ELITE:
				ability_datas.append(GALE_DEBRIS_ABILITY.get_duplicate())
			else:
				ability_datas.append(GALE_DEBRIS_ABILITY.get_duplicate())
		4:
			if combat_type == CombatData.CombatType.ELITE:
				ability_datas.append(GALE_DEBRIS_ABILITY.get_duplicate())
			ability_datas.append(GALE_DEBRIS_ABILITY.get_duplicate())
		5:
			for i in field_indices.size() - 1:
				ability_datas.append(GALE_DEBRIS_ABILITY.get_duplicate())
			ability_datas.append(GALE_DEBRIS_ABILITY.get_duplicate())
	
	fields_have_abilities = field_indices.slice(0, ability_datas.size()).duplicate()
	abilities = _instantiate_abilities(ability_datas)
	for ability:WeatherAbility in abilities:
		ability.field_index = fields_have_abilities.pop_front()
	return abilities


#endregion
