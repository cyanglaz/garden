class_name WeatherManager
extends RefCounted

signal weathers_updated()
signal all_weather_actions_applied()

const WEATHER_SUNNY := preload("res://data/weathers/all_chapters/weather_sunny.tres")
const WEATHER_RAINY := preload("res://data/weathers/all_chapters/weather_rainy.tres")

const WEATHER_APPLICATION_ICON_START_DELAY := 0.05

const GUI_WEATHER_SCENE := preload("res://scenes/GUI/main_game/weather/gui_weather.tscn")

#var level:int
var weathers:Array[WeatherData]
var forecast_days := 4

func generate_next_weathers(chapter:int) -> void:
	for _day in forecast_days - weathers.size():
		_generate_next_weather(chapter)
	weathers_updated.emit()

func pass_day() -> void:
	weathers.pop_front()
	weathers_updated.emit()

func get_current_weather() -> WeatherData:
	return weathers.front()

func get_forecasts() -> Array[WeatherData]:
	var forecast := weathers.slice(1, 1 + forecast_days)
	return forecast

func apply_weather_actions(fields:Array[Field], combat_main:CombatMain) -> void:
	await _apply_weather_action_to_next_field(fields, 0, combat_main)

func apply_weather_tool_action(action:ActionData, icon_move_start_position:Vector2, combat_main:CombatMain) -> void:
	assert(action.action_category == ActionData.ActionCategory.WEATHER)
	weathers.pop_front()
	match action.type:
		ActionData.ActionType.WEATHER_SUNNY:
			weathers.push_front(WEATHER_SUNNY.get_duplicate())
		ActionData.ActionType.WEATHER_RAINY:
			weathers.push_front(WEATHER_RAINY.get_duplicate())
		_:
			assert(false, "Invalid action type for weather tool: " + str(action.action_type))
	await combat_main.gui.gui_weather_container.animate_weather_update(weathers.front(), icon_move_start_position)
	weathers_updated.emit()

func _generate_next_weather(chapter:int) -> void:
	var available_weathers := MainDatabase.weather_database.get_weathers_by_chapter(chapter)
	var weather:WeatherData = available_weathers.pick_random().get_duplicate()
	weathers.append(weather)

func _apply_weather_action_to_next_field(fields:Array[Field], field_index:int, combat_main:CombatMain) -> void:
	if field_index >= fields.size():
		all_weather_actions_applied.emit()
		return
	var field:Field = fields[field_index]
	var today_weather:WeatherData = get_current_weather()
	if !_should_weather_be_applied(today_weather, field):
		await _apply_weather_action_to_next_field(fields, field_index + 1, combat_main)
	else:
		await combat_main.gui.gui_weather_container.animate_weather_application(today_weather, field)
		await field.apply_weather_actions(today_weather, combat_main)
		await _apply_weather_action_to_next_field(fields, field_index + 1, combat_main)

func _should_weather_be_applied(weather_data:WeatherData, field:Field) -> bool:
	if weather_data.actions.is_empty():
		return false
	for action:ActionData in weather_data.actions:
		if field.is_action_applicable(action):
			return true
	return false
