class_name WeatherMain
extends Node2D

const NIGHT_CANVAS_MODULATE_COLOR := Constants.COLOR_GRAY4
const DAY_CANVAS_MODULATE_COLOR := Constants.COLOR_WHITE
const WEATHER_TRASITION_TIME := 0.3

const WEATHER_SCENE_PREFIX := "res://scenes/main_game/combat/weather/weathers/weather_%s.tscn"

signal weathers_updated()

@export var test_weather:WeatherData

@onready var _weather_container: Node2D = %WeatherContainer
@onready var _weather_sky: WeatherSky = %WeatherSky
@onready var _canvas_modulate: CanvasModulate = %CanvasModulate
@onready var _weather_ability_container: WeatherAbilityContainer = %WeatherAbilityContainer

var weather_manager:WeatherManager = WeatherManager.new()

var _current_weather:Weather

func apply_weather_actions(plants:Array[Plant], combat_main:CombatMain) -> void:
	await weather_manager.apply_weather_actions(plants, combat_main)

func apply_weather_tool_action(action:ActionData, icon_move_start_position:Vector2, combat_main:CombatMain) -> void:
	await weather_manager.apply_weather_tool_action(action, icon_move_start_position, combat_main)

func start(chapter:int) -> void:
	weather_manager.test_weather = test_weather
	weather_manager.start(chapter)
	assert(_current_weather == null)
	var current_weather := weather_manager.get_current_weather()
	_add_new_weather(current_weather)
	await _current_weather.animate_in()
	weathers_updated.emit()

func generate_next_weather_abilities(combat_main:CombatMain, turn_index:int) -> void:
	_weather_ability_container.generate_next_weather_abilities(get_current_weather(), combat_main, turn_index)

func apply_weather_abilities(plants:Array, combat_main:CombatMain) -> void:
	await _weather_ability_container.apply_weather_actions(plants, combat_main)

func level_end_stop() -> void:
	if _current_weather:
		_current_weather.stop()
		_current_weather.queue_free()
		_current_weather = null
	_weather_ability_container.clear_all_weather_abilities()

func night_fall() -> void:
	if _current_weather:
		await _current_weather.animate_out()
		_current_weather.queue_free()
		_current_weather = null
	var tween_night:Tween = Util.create_scaled_tween(_canvas_modulate)
	tween_night.tween_property(_canvas_modulate, "color", NIGHT_CANVAS_MODULATE_COLOR, WEATHER_TRASITION_TIME/2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween_night.finished

func pass_day() -> void:
	weather_manager.pass_day()
	await _update_weather_scene()
	weathers_updated.emit()

func get_current_weather() -> WeatherData:
	return weather_manager.get_current_weather()

func _update_weather_scene() -> void:
	var current_weather := weather_manager.get_current_weather()
	await _animate_transition_to_weather(current_weather)
	weathers_updated.emit()

func _animate_transition_to_weather(new_weather:WeatherData) -> void:
	_add_new_weather(new_weather)
	var tween_day:Tween = Util.create_scaled_tween(_canvas_modulate)
	tween_day.tween_property(_canvas_modulate, "color", DAY_CANVAS_MODULATE_COLOR, WEATHER_TRASITION_TIME/2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween_day.finished
	await _current_weather.animate_in()

func _add_new_weather(new_weather:WeatherData) -> void:
	var new_weather_container_scene := load(str(WEATHER_SCENE_PREFIX % new_weather.id))
	_current_weather = new_weather_container_scene.instantiate()
	_weather_container.add_child(_current_weather)
	_weather_sky.color = new_weather.sky_color
