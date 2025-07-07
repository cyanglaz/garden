class_name WeatherManager
extends RefCounted

signal weathers_updated()

const WEATHER_SUNNY := preload("res://data/weathers/weather_sunny.tres")
const WEATHER_RAINY := preload("res://data/weathers/weather_rainy.tres")

const WEATHER_APPLICATION_ICON_START_DELAY := 0.05
const WEATHER_APPLICATION_ICON_MOVE_TIME := 0.3
const WEATHER_TOOL_ACTION_ICON_MOVE_TIME := 0.5

const GUI_WEATHER_SCENE := preload("res://scenes/GUI/main_game/weather/gui_weather.tscn")

#var week:int
var weathers:Array[WeatherData]
var forecast_days := 1
var day:int = 0: set = _set_day

func generate_weathers(number_of_weathers:int, week:int) -> void:
	weathers = MainDatabase.weather_database.roll_weathers(number_of_weathers, week)
	weathers_updated.emit()

func get_current_weather() -> WeatherData:
	return weathers[day]

func get_forecasts() -> Array[WeatherData]:
	if day == weathers.size():
		return []
	var forecast := weathers.slice(day + 1, day + 1 + forecast_days)
	return forecast

func apply_weather_actions(fields:Array[Field], today_weather_icon:GUIWeather) -> void:
	var gui_weather_copies:Array[GUIWeather] = []
	var tween:Tween = Util.create_scaled_tween(today_weather_icon)
	tween.set_parallel(true)
	tween.tween_interval(0.01) #When weather is cloudy, nothing happens, give it a tiny delay tween to suppress no tweener warning.
	var delay := 0.0
	var today_weather:WeatherData = get_current_weather()
	var fields_to_apply_weather_actions:Array[Field] = []
	for field:Field in fields:
		if _should_weather_be_applied(today_weather, field):
			fields_to_apply_weather_actions.append(field)
	if fields_to_apply_weather_actions.is_empty():
		return
	
	for field:Field in fields_to_apply_weather_actions:
		var gui_weather_copy := GUI_WEATHER_SCENE.instantiate()
		Singletons.main_game.add_control_to_overlay(gui_weather_copy)
		gui_weather_copy.global_position = today_weather_icon.global_position
		gui_weather_copy.setup_with_weather_data(today_weather)
		var target_position:Vector2 = Util.get_node_ui_position(gui_weather_copy, field) \
				- gui_weather_copy.size/2 \
				+ Vector2.UP * 24
		var sound_timer:= Util.create_scaled_timer(delay)
		sound_timer.timeout.connect(func() -> void: gui_weather_copy.play_flying_sound())
		tween.tween_property(
			gui_weather_copy,
			"global_position", 
			target_position,
			WEATHER_APPLICATION_ICON_MOVE_TIME
		).set_delay(delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		delay += WEATHER_APPLICATION_ICON_START_DELAY
		gui_weather_copies.append(gui_weather_copy)
	await tween.finished
	await Util.await_for_small_time()
	for field:Field in fields_to_apply_weather_actions:
		field.apply_weather_actions(today_weather)
	await Util.create_scaled_timer(0.5).timeout
	for gui_weather_copy:GUIWeather in gui_weather_copies:
		gui_weather_copy.queue_free()

func apply_weather_tool_action(action:ActionData, icon_move_start_position:Vector2, icon_move_target_position:Vector2) -> void:
	await Util.await_for_tiny_time()
	assert(action.action_category == ActionData.ActionCategory.WEATHER)
	match action.type:
		ActionData.ActionType.WEATHER_SUNNY:
			weathers[day] = WEATHER_SUNNY.get_duplicate()
		ActionData.ActionType.WEATHER_RAINY:
			weathers[day] = WEATHER_RAINY.get_duplicate()
		_:
			assert(false, "Invalid action type for weather tool: " + str(action.action_type))
	await _animate_weather_icon_move(weathers[day], icon_move_start_position, icon_move_target_position)
	weathers_updated.emit()

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

func _set_day(value:int) -> void:
	day = value
	weathers_updated.emit()
