class_name GUIWeatherContainer
extends VBoxContainer

const FORECAST_SIZE_SCALE := 0.7
const WEATHER_APPLICATION_ICON_MOVE_TIME := 0.3
const WEATHER_TOOL_ACTION_ICON_MOVE_TIME := 0.5
const WEATHER_ICON_ANIMATION_HEIGHT := 40

const GUI_WEATHER_SCENE := preload("res://scenes/GUI/main_game/weather/gui_weather.tscn")

@onready var _today_weather_icon: GUIWeather = %TodayWeatherIcon
@onready var _forecast_container: VBoxContainer = %ForcastContainer
@onready var _animation_container: Control = %AnimationContainer

func update_with_weather_manager(weather_manager:WeatherManager) -> void:
	Util.remove_all_children(_forecast_container)
	var today_weather := weather_manager.get_current_weather()
	_today_weather_icon.setup_with_weather_data(today_weather)
	_today_weather_icon.has_tooltip = true
	var forecasts := weather_manager.get_forecasts()
	for weather_data:WeatherData in forecasts:
		var gui_weather := GUI_WEATHER_SCENE.instantiate()
		gui_weather.has_tooltip = true
		var gui_weather_size:float = gui_weather.custom_minimum_size.x
		var scaled_size := floori(gui_weather_size * FORECAST_SIZE_SCALE)
		gui_weather.custom_minimum_size = Vector2(scaled_size, scaled_size)
		_forecast_container.add_child(gui_weather)
		gui_weather.setup_with_weather_data(weather_data)

func animate_weather_application(today_weather:WeatherData, plant:Plant) -> void:
	var gui_weather_copy := GUI_WEATHER_SCENE.instantiate()
	var tween:Tween = Util.create_scaled_tween(gui_weather_copy)
	_animation_container.add_child(gui_weather_copy)
	var today_weather_icon:GUIWeather = get_today_weather_icon()
	gui_weather_copy.global_position = today_weather_icon.global_position
	gui_weather_copy.setup_with_weather_data(today_weather)
	var target_position:Vector2 = Util.get_node_canvas_position(plant) \
			- gui_weather_copy.size/2 \
			+ Vector2.UP * WEATHER_ICON_ANIMATION_HEIGHT
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

func animate_weather_update(weather_data:WeatherData, start_position:Vector2) -> void:
	var target_position := get_today_weather_icon().global_position
	var gui_weather_copy := GUI_WEATHER_SCENE.instantiate()
	_animation_container.add_child(gui_weather_copy)
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

func get_today_weather_icon() -> GUIWeather:
	return _today_weather_icon
