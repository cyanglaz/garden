class_name PlantSunflower
extends Plant

func _trigger_end_day_ability(weather_data:WeatherData, _day:int) -> void:

	if weather_data.id == "sunny" && stage == 2:
		var action_data:ActionData = ActionData.new()
		action_data.type = ActionData.ActionType.LIGHT
		action_data.value = data.data["light"] as int
		await field.apply_actions([action_data])
	else:
		await Util.await_for_tiny_time()
	end_day_ability_triggered.emit()
