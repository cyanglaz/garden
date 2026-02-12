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

func apply_to_player(combat_main:CombatMain) -> void:
	var player_actions:Array = weather_ability_data.action_datas.filter(func(action:ActionData): return action.action_category == ActionData.ActionCategory.PLAYER)
	if player_actions.is_empty():
		await _apply_to_player_with_script(combat_main)
		return
	await _apply_actions_to_player(combat_main, player_actions)

func apply_to_plant(plant:Plant, combat_main:CombatMain) -> void:
	var plant_actions:Array = weather_ability_data.action_datas.filter(func(action:ActionData): return action.action_category == ActionData.ActionCategory.FIELD)
	if plant_actions.is_empty():
		await _apply_to_plant_with_script(plant, combat_main)
		return
	await _apply_actions_to_plant(plant, combat_main, plant_actions)

#region private functions

func _apply_actions_to_player(combat_main:CombatMain, action_datas:Array[ActionData]) -> void:
	_pending_actions = action_datas.duplicate()
	_action_index = 0
	await _apply_next_player_action(combat_main)

func _apply_next_player_action(combat_main:CombatMain) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		return
	var action:ActionData = _pending_actions[_action_index]
	action.value += level
	_action_index += 1
	await player_actions_applier.apply_action(action, combat_main, [])
	await _apply_next_player_action(combat_main)

func _apply_actions_to_plant(plant:Plant, combat_main:CombatMain, action_datas:Array[ActionData]) -> void:
	_pending_actions = action_datas.duplicate()
	_action_index = 0
	await _apply_next_plant_action(plant, combat_main)
	
func _apply_next_plant_action(plant:Plant, combat_main:CombatMain) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		return
	var action:ActionData = _pending_actions[_action_index]
	action.value += level
	_action_index += 1
	await plant_actions_applier.apply_action(action, plant, combat_main)
	await _apply_next_plant_action(plant, combat_main)

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
	if field_index > FieldContainer.MAX_FIELDS/2:
		_weather_ability_icon.tooltip_position = GUITooltip.TooltipPosition.LEFT
	else:
		_weather_ability_icon.tooltip_position = GUITooltip.TooltipPosition.RIGHT
		
