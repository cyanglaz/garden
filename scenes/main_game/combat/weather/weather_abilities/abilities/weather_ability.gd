class_name WeatherAbility
extends Node2D

const ICON_PREFIX := "res://resources/sprites/GUI/icons/weather_ability/icon_%s.png"

var player_actions_applier:PlayerActionApplier = PlayerActionApplier.new()
var plant_actions_applier:PlantActionApplier = PlantActionApplier.new()
var level:int = 0
var field_index:int = -1: set = _set_field_index

var _pending_actions:Array[ActionData] = []
var _action_index:int = 0

@onready var _weather_ability_icon: WeatherAbilityIcon = %WeatherAbilityIcon

var weather_ability_data:WeatherAbilityData

func _ready() -> void:
	_weather_ability_icon.setup_with_weather_ability_data(weather_ability_data, level)
	_set_field_index(field_index)

func setup_with_weather_ability_data(data:WeatherAbilityData) -> void:
	weather_ability_data = data

func hide_icon() -> void:
	_weather_ability_icon.hide()

func queue_player_actions(combat_main:CombatMain) -> void:
	var player_actions:Array = weather_ability_data.action_datas.filter(func(action:ActionData): return action.action_category == ActionData.ActionCategory.PLAYER)
	if player_actions.is_empty():
		var script_request = CombatQueueRequest.new()
		script_request.front = true
		script_request.callback = func(_cm: CombatMain) -> void: await _apply_to_player_with_script(combat_main)
		Events.request_combat_queue_push.emit(script_request)
		return
	player_actions.reverse()
	for action:ActionData in player_actions:
		var request = CombatQueueRequest.new()
		request.front = true
		request.callback = func(_cm: CombatMain) -> void: await player_actions_applier.apply_action(action, combat_main, [])
		Events.request_combat_queue_push.emit(request)

func queue_plant_actions(plant:Plant, combat_main:CombatMain) -> void:
	var plant_actions:Array = weather_ability_data.action_datas.filter(func(action:ActionData): return action.action_category == ActionData.ActionCategory.FIELD)
	if plant_actions.is_empty():
		var script_request = CombatQueueRequest.new()
		script_request.front = true
		script_request.callback = func(_cm: CombatMain) -> void: await _apply_to_plant_with_script(plant, combat_main)
		Events.request_combat_queue_push.emit(script_request)
		return
	plant_actions.reverse()
	for action:ActionData in plant_actions:
		var request = CombatQueueRequest.new()
		request.front = true
		request.callback = func(_cm: CombatMain) -> void: await plant_actions_applier.apply_action(action, plant, combat_main)
		Events.request_combat_queue_push.emit(request)

#region for override

func _apply_to_player_with_script(_combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

func _apply_to_plant_with_script(_plant:Plant, _combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

#endregion

func _set_field_index(value:int) -> void:
	field_index = value
	if !_weather_ability_icon:
		return
	@warning_ignore("integer_division")
	_weather_ability_icon.position_index_offset = field_index - FieldContainer.MAX_FIELDS/2
