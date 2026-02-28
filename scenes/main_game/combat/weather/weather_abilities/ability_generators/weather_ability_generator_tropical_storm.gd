class_name WeatherAbilityGeneratorTropicalStorm
extends WeatherAbilityGenerator

const FLASH_FLOOD_ABILITY := preload("res://data/weather_abilities/weather_ability_flash_flood.tres")
const LIGHTNING_STRIKE_ABILITY := preload("res://data/weather_abilities/weather_ability_lightning_strike.tres")

const LIGHTNING_STRIKE_CHANCE := 0.5
const NUMBER_OF_ABILITY_CHANCE := {
	1: 1,
	2: 3,
	3: 3,
	4: 2,
	5: 1
}

#region for override
func _generate_abilities(combat_main:CombatMain, _turn_index:int) -> Array[WeatherAbility]:
	var abilities:Array[WeatherAbility] = []
	var field_indices := range(combat_main.plant_field_container.plants.size())
	field_indices.shuffle()
	var number_of_abilities:int = Util.weighted_roll(NUMBER_OF_ABILITY_CHANCE.keys(), NUMBER_OF_ABILITY_CHANCE.values())
	var is_lightning_strike:bool = randf() < LIGHTNING_STRIKE_CHANCE
	var ability_datas:Array[WeatherAbilityData] = []
	for i in number_of_abilities:
		if is_lightning_strike:
			ability_datas.append(LIGHTNING_STRIKE_ABILITY.get_duplicate())
		else:
			ability_datas.append(FLASH_FLOOD_ABILITY.get_duplicate())

	var fields_have_abilities:Array = field_indices.slice(0, ability_datas.size()).duplicate()
	abilities = _instantiate_abilities(ability_datas)
	for ability:WeatherAbility in abilities:
		ability.field_index = fields_have_abilities.pop_front()
	return abilities


#endregion
