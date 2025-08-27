class_name PlantSunflower
extends Plant

func _has_ability(ability_type:AbilityType) -> bool:
	return ability_type == AbilityType.WEATHER

func _trigger_ability(ability_type:AbilityType, main_game:MainGame) -> void:
	assert(ability_type == AbilityType.WEATHER)
	var weather_data:WeatherData = main_game.weather_manager.get_current_weather()
	if weather_data.id == "sunny":
		var action_data:ActionData = ActionData.new()
		action_data.type = ActionData.ActionType.LIGHT
		action_data.value = data.data["light"] as int
		await field.apply_actions([action_data])
