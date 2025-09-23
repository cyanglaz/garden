class_name WeatherManager
extends RefCounted

signal weathers_updated()
signal all_weather_actions_applied()

const WEATHER_SUNNY := preload("res://data/weathers/all_chapters/weather_sunny.tres")
const WEATHER_RAINY := preload("res://data/weathers/all_chapters/weather_rainy.tres")

const WEATHER_APPLICATION_ICON_START_DELAY := 0.05
const WEATHER_APPLICATION_ICON_MOVE_TIME := 0.3
const WEATHER_TOOL_ACTION_ICON_MOVE_TIME := 0.5

const GUI_WEATHER_SCENE := preload("res://scenes/GUI/main_game/weather/gui_weather.tscn")

#var level:int
var weathers:Array[WeatherData]
var forecast_days := 4

func generate_next_weathers(chapter:int) -> void:
	if !weathers.is_empty():
		weathers.pop_front()
	for _day in forecast_days - weathers.size():
		_generate_next_weather(chapter)
	weathers_updated.emit()

func get_current_weather() -> WeatherData:
	return weathers.front()

func get_forecasts() -> Array[WeatherData]:
	var forecast := weathers.slice(1, 1 + forecast_days)
	return forecast

func apply_weather_actions(fields:Array[Field], today_weather_icon:GUIWeather) -> void:
	await _apply_weather_action_to_next_field(fields, 0, today_weather_icon)

func apply_weather_tool_action(action:ActionData, icon_move_start_position:Vector2, icon_move_target_position:Vector2) -> void:
	await Util.await_for_tiny_time()
	assert(action.action_category == ActionData.ActionCategory.WEATHER)
	weathers.pop_front()
	match action.type:
		ActionData.ActionType.WEATHER_SUNNY:
			weathers.push_front(WEATHER_SUNNY.get_duplicate())
		ActionData.ActionType.WEATHER_RAINY:
			weathers.push_front(WEATHER_RAINY.get_duplicate())
		_:
			assert(false, "Invalid action type for weather tool: " + str(action.action_type))
	await _animate_weather_icon_move(weathers.front(), icon_move_start_position, icon_move_target_position)
	weathers_updated.emit()

func _generate_next_weather(chapter:int) -> void:
	var available_weathers := MainDatabase.weather_database.get_weathers_by_chapter(chapter)
	var weather:WeatherData = available_weathers.pick_random().get_duplicate()
	weathers.append(weather)

func _apply_weather_action_to_next_field(fields:Array[Field], field_index:int, today_weather_icon:GUIWeather) -> void:
	if field_index >= fields.size():
		all_weather_actions_applied.emit()
		return
	var field:Field = fields[field_index]
	var today_weather:WeatherData = get_current_weather()
	if !_should_weather_be_applied(today_weather, field):
		await _apply_weather_action_to_next_field(fields, field_index + 1, today_weather_icon)
	else:
		var tween:Tween = Util.create_scaled_tween(today_weather_icon)
		var gui_weather_copy := GUI_WEATHER_SCENE.instantiate()
		Singletons.main_game.add_control_to_overlay(gui_weather_copy)
		gui_weather_copy.global_position = today_weather_icon.global_position
		gui_weather_copy.setup_with_weather_data(today_weather)
		var target_position:Vector2 = Util.get_node_ui_position(gui_weather_copy, field) \
				- gui_weather_copy.size/2 \
				+ Vector2.UP * 24
		gui_weather_copy.play_flying_sound()
		tween.tween_property(
			gui_weather_copy,
			"global_position", 
			target_position,
			WEATHER_APPLICATION_ICON_MOVE_TIME
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await tween.finished
		var disappear_tween:Tween = Util.create_scaled_tween(gui_weather_copy)
		disappear_tween.tween_property(gui_weather_copy, "modulate:a", 0, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		disappear_tween.finished.connect(func() -> void: gui_weather_copy.queue_free())
		await field.apply_weather_actions(today_weather)
		await _apply_weather_action_to_next_field(fields, field_index + 1, today_weather_icon)

func _animate_weather_icon_move(weather_data:WeatherData, start_position:Vector2, target_position:Vector2) -> void:
	var gui_weather_copy := GUI_WEATHER_SCENE.instantiate()
	Singletons.main_game.add_control_to_overlay(gui_weather_copy)
	gui_weather_copy.global_position = start_position
	gui_weather_copy.setup_with_weather_data(weather_data)
	gui_weather_copy.play_flying_sound()
	var tween:Tween = Util.create_scaled_tween(gui_weather_copy)
	tween.tween_property(
		gui_weather_copy,
		"global_position",
		target_position,
		WEATHER_TOOL_ACTION_ICON_MOVE_TIME
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished
	await Util.await_for_small_time()
	gui_weather_copy.queue_free()

func _should_weather_be_applied(weather_data:WeatherData, field:Field) -> bool:
	if weather_data.actions.is_empty():
		return false
	for action:ActionData in weather_data.actions:
		if field.is_action_applicable(action):
			return true
	return false
