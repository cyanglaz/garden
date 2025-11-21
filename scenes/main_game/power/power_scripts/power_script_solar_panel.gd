class_name PowerScriptSolarPanel
extends PowerScript

var _action_count := 0
signal _all_action_application_completed()

func _has_weather_application_hook(_combat_main:CombatMain, weather_data:WeatherData) -> bool:
	return weather_data.id == "sunny" || weather_data.id == "cloudy"

func _handle_weather_application_hook(combat_main:CombatMain, _weather_data:WeatherData) -> void:
	var action_data:ActionData = ActionData.new()
	action_data.type = ActionData.ActionType.LIGHT
	action_data.value = power_data.stack
	action_data.operator_type = ActionData.OperatorType.INCREASE
	action_data.specials.append(ActionData.Special.ALL_FIELDS)
	_action_count = combat_main.plant_field_container.plants.size()
	assert(_action_count > 0)
	for plant:Plant in combat_main.plant_field_container.plants:
		plant.action_application_completed.connect(_on_action_application_completed.bind(plant))
		plant.apply_actions([action_data])
	await _all_action_application_completed

func _on_action_application_completed(plant:Plant) -> void:
	plant.action_application_completed.disconnect(_on_action_application_completed.bind(plant))
	_action_count -= 1
	if _action_count == 0:
		_all_action_application_completed.emit()
