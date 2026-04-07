class_name WeatherAbilityGeneratorShower
extends WeatherAbilityGenerator

const HEAVY_DROPLET_ABILITY := preload("res://data/weather_abilities/weather_ability_heavy_droplet.tres")
const FLASH_FLOOD_ABILITY := preload("res://data/weather_abilities/weather_ability_flash_flood.tres")

const TURNS_TO_INCREASE_RAIN := 2

#region for override
func _generate_abilities(combat_main:CombatMain, turn_index:int) -> Array[WeatherAbility]:
	var abilities:Array[WeatherAbility] = []
	var field_indices := range(combat_main.plant_field_container.plants.size())
	field_indices.shuffle()
	var fields_have_abilities:Array
	var ability_datas:Array[WeatherAbilityData]
	@warning_ignore("integer_division")
	var rain_count := mini(turn_index / TURNS_TO_INCREASE_RAIN + 1, field_indices.size())
	for i in rain_count:
		ability_datas.append(HEAVY_DROPLET_ABILITY.get_duplicate())
	if combat_type == CombatData.CombatType.ELITE && rain_count > 1:
		ability_datas.pop_back()
		ability_datas.append(FLASH_FLOOD_ABILITY.get_duplicate())
	
	fields_have_abilities = field_indices.slice(0, ability_datas.size()).duplicate()
	abilities = _instantiate_abilities(ability_datas)
	for ability:WeatherAbility in abilities:
		ability.field_index = fields_have_abilities.pop_front()
	return abilities


#endregion
