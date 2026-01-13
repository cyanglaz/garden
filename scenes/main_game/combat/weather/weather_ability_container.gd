class_name WeatherAbilityContainer
extends Node2D

const ABILITY_Y_OFFSET := 70

signal weathers_abilities_updated()
signal all_weather_actions_applied()

const WEATHER_ABILITIES_SCENE_PREFIX := "res://scenes/main_game/combat/weather/weather_abilities/abilities/weather_ability_%s.tscn"
const ABILITY_GENERATOR_SCENE_PREFIX := "res://scenes/main_game/combat/weather/weather_abilities/ability_generators/weather_ability_generator_%s.gd"

var weather_abilities:Array

var _ability_generator:WeatherAbilityGenerator

@onready var ability_container: Node2D = %AbilityContainer
@onready var weather_ability_animation_container: WeatherAbilityAnimationContainer = %WeatherAbilityAnimationContainer

func setup_with_weather_data(weather_data:WeatherData) -> void:
	if !_ability_generator:
		var ability_generator_script:GDScript = load(ABILITY_GENERATOR_SCENE_PREFIX % weather_data.id)
		_ability_generator = ability_generator_script.new()
		_ability_generator.setup_with_weather_data(weather_data)

func generate_next_weather_abilities(combat_main:CombatMain, turn_index:int) -> void:
	clear_all_weather_abilities()
	var generated_abilities:Array[WeatherAbility] = _ability_generator.generate_abilities(combat_main, turn_index)
	for weather_ability:WeatherAbility in generated_abilities:
		ability_container.add_child(weather_ability)
		weather_abilities.append(weather_ability)
		var field_position:Vector2 = combat_main.plant_field_container.get_field(weather_ability.field_index).global_position
		weather_ability.global_position = field_position + Vector2.UP * ABILITY_Y_OFFSET
	weathers_abilities_updated.emit()

func apply_weather_actions(plants:Array, combat_main:CombatMain) -> void:
	await _apply_weather_action_to_next_plant(plants, plants.size() - 1, combat_main)

func clear_all_weather_abilities() -> void:
	Util.remove_all_children(ability_container)
	weather_abilities.clear()

func _apply_weather_action_to_next_plant(plants:Array, plant_index:int, combat_main:CombatMain) -> void:
	if plant_index < 0:
		all_weather_actions_applied.emit()
		return
	var ability_index:int = Util.array_find(weather_abilities, func(ability:WeatherAbility): return ability.field_index == plant_index)
	if ability_index == -1:
		await _apply_weather_action_to_next_plant(plants, plant_index - 1, combat_main)
		return
	var weather_ability:WeatherAbility = weather_abilities[ability_index]
	var player = combat_main.player
	var player_index:int = player.current_field_index
	weather_ability.hide_icon()
	if plant_index == player_index:
		await weather_ability_animation_container.run_animation(weather_ability, player.global_position, true)
		await weather_ability.apply_to_player(player, combat_main)
	else:
		await weather_ability_animation_container.run_animation(weather_ability, plants[plant_index].global_position, false)
		await weather_ability.apply_to_plant(plants, plant_index, combat_main)
	await _apply_weather_action_to_next_plant(plants, plant_index - 1, combat_main)
