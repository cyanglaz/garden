class_name WeatherManager
extends RefCounted

signal weathers_updated()
signal all_weather_actions_applied()

const WEATHER_SUNNY := preload("res://data/weathers/all_chapters/weather_sunny.tres")
const WEATHER_RAINY := preload("res://data/weathers/all_chapters/weather_tropical_storm.tres")

const WEATHER_APPLICATION_ICON_START_DELAY := 0.05

const GUI_WEATHER_SCENE := preload("res://scenes/GUI/main_game/weather/gui_weather.tscn")

var test_weather:WeatherData

#var level:int
var weathers:Array[WeatherData]
var forecast_days := 1
var _chapter:int

func start(chapter:int) -> void:
	_chapter = chapter
	_generate_next_weathers(_chapter)

func pass_day() -> void:
	weathers.pop_front()
	_generate_next_weathers(_chapter)

func _generate_next_weathers(chapter:int) -> void:
	for _day in forecast_days - weathers.size():
		_generate_next_weather(chapter)
	weathers_updated.emit()

func get_current_weather() -> WeatherData:
	return weathers.front()

func get_forecasts() -> Array[WeatherData]:
	var forecast := weathers.slice(1, 1 + forecast_days)
	return forecast

func apply_weather_actions(plants:Array[Plant], combat_main:CombatMain) -> void:
	await _apply_weather_action_to_next_plant(plants, plants.size() - 1, combat_main)

func apply_weather_tool_action(action:ActionData, icon_move_start_position:Vector2, combat_main:CombatMain) -> void:
	assert(action.action_category == ActionData.ActionCategory.WEATHER)
	weathers.pop_front()
	match action.type:
		ActionData.ActionType.WEATHER_RAINY:
			weathers.push_front(WEATHER_RAINY.get_duplicate())
		_:
			assert(false, "Invalid action type for weather tool: " + str(action.action_type))
	await combat_main.gui.gui_weather_container.animate_weather_update(weathers.front(), icon_move_start_position)
	weathers_updated.emit()

func _generate_next_weather(chapter:int) -> void:
	if test_weather:
		weathers.append(test_weather.get_duplicate())
		return
	var available_weathers := MainDatabase.weather_database.get_weathers_by_chapter(chapter)
	var weather:WeatherData = available_weathers.pick_random().get_duplicate()
	weathers.append(weather)

func _apply_weather_action_to_next_plant(plants:Array[Plant], plant_index:int, combat_main:CombatMain) -> void:
	if plant_index < 0:
		all_weather_actions_applied.emit()
		return
	var plant:Plant = plants[plant_index]
	var today_weather:WeatherData = get_current_weather()
	if !_should_weather_be_applied(today_weather, plant):
		await _apply_weather_action_to_next_plant(plants, plant_index - 1, combat_main)
	else:
		await combat_main.gui.gui_weather_container.animate_weather_application(today_weather, plant)
		await plant.apply_weather_actions(today_weather)
		await _apply_weather_action_to_next_plant(plants, plant_index - 1, combat_main)

func _should_weather_be_applied(weather_data:WeatherData, plant:Plant) -> bool:
	if weather_data.actions.is_empty():
		return false
	if plant.is_bloom():
		return false
	for action:ActionData in weather_data.actions:
		return true
	return false
