class_name PlantSunflower
extends Plant

func _trigger_ability(ability_type:AbilityType, main_game:MainGame) -> void:
	if ability_type != AbilityType.END_DAY:
		await Util.await_for_tiny_time()
		return
	var weather_data:WeatherData = main_game.weather_manager.get_current_weather()
	if weather_data.id == "sunny" && stage == 2:
		var action_data:ActionData = ActionData.new()
		action_data.type = ActionData.ActionType.LIGHT
		action_data.value = data.data["light"] as int
		await field.apply_actions([action_data])
