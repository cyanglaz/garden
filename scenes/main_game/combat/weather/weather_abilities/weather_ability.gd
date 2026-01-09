class_name WeatherAbility
extends Node2D

const ICON_PREFIX := "res://resources/sprites/GUI/icons/weather_ability/icon_%s.png"

var player_actions_applier:PlayerActionApplier = PlayerActionApplier.new()
var plant_actions_applier:PlantActionApplier = PlantActionApplier.new()

var _pending_actions:Array[ActionData] = []
var _action_index:int = 0

@onready var _weather_ability_icon: WeatherAbilityIcon = %WeatherAbilityIcon

var _weather_ability_data:WeatherAbilityData

func setup_with_weather_ability_data(data:WeatherAbilityData) -> void:
	_weather_ability_icon.setup_with_weather_ability_data(data)
	_weather_ability_data = data

func apply_to_player(_player:Player, _combat_main:CombatMain) -> void:
	_weather_ability_icon.hide()
	await _run_animation(_player.global_position, true)
	var player_actions:Array = _weather_ability_data.action_datas.filter(func(action:ActionData): return action.action_category == ActionData.ActionCategory.PLAYER)
	if player_actions.is_empty():
		await _apply_to_player_with_script(_player, _combat_main)
		return
	_apply_actions_to_player(_player, _combat_main, player_actions)

func apply_to_plant(plants:Array, plant_index:int, _combat_main:CombatMain) -> void:
	_weather_ability_icon.hide()
	await _run_animation(plants[plant_index].global_position, false)
	var plant_actions:Array = _weather_ability_data.action_datas.filter(func(action:ActionData): return action.action_category == ActionData.ActionCategory.FIELD)
	if plant_actions.is_empty():
		await _apply_to_plant_with_script(plants, plant_index, _combat_main)
		return
	_apply_actions_to_plant(plants, plant_index, _combat_main, plant_actions)

#region private functions

func _apply_actions_to_player(player:Player, combat_main:CombatMain, action_datas:Array[ActionData]) -> void:
	_pending_actions = action_datas.duplicate()
	_action_index = 0
	await _apply_next_player_action(player, combat_main)

func _apply_next_player_action(player:Player, combat_main:CombatMain) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		return
	var action:ActionData = _pending_actions[_action_index]
	_action_index += 1
	await player_actions_applier.apply_action(action, combat_main, [])
	await _apply_next_player_action(player, combat_main)

func _apply_actions_to_plant(plants:Array, plant_index:int, _combat_main:CombatMain, action_datas:Array[ActionData]) -> void:
	_pending_actions = action_datas.duplicate()
	_action_index = 0
	await _apply_next_plant_action(plants, plant_index, _combat_main)
	
func _apply_next_plant_action(plants:Array, plant_index:int, _combat_main:CombatMain) -> void:
	if _action_index >= _pending_actions.size():
		_pending_actions.clear()
		_action_index = 0
		return
	var action:ActionData = _pending_actions[_action_index]
	_action_index += 1
	await plant_actions_applier.apply_action(action, plants, plant_index)
	await _apply_next_plant_action(plants, plant_index, _combat_main)

#region for override

func _run_animation(_target_position:Vector2, _blocked_by_player:bool) -> void:
	await Util.await_for_tiny_time()

func _apply_to_player_with_script(_player:Player, _combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

func _apply_to_plant_with_script(_plants:Array, _plant_index:int, _combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

#endregion
