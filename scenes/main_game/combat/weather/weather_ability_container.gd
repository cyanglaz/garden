class_name WeatherAbilityContainer
extends Node2D

const ABILITY_Y_OFFSET := 70

signal weathers_abilities_updated()
signal all_weather_actions_applied()

const WEATHER_ABILITIES_SCENE_PREFIX := "res://scenes/main_game/combat/weather/weather_abilities/weather_ability_%s.tscn"

var weather_abilities:Array

func generate_next_weather_abilities(weather_data:WeatherData, combat_main:CombatMain) -> void:
	for i in combat_main.plant_field_container.plants.size():
		var random_ability:WeatherAbilityData = Util.unweighted_roll(weather_data.abilities, 1)[0]
		var weather_ability_scene:PackedScene = load(WEATHER_ABILITIES_SCENE_PREFIX % random_ability.id)
		var weather_ability:WeatherAbility = weather_ability_scene.instantiate()
		add_child(weather_ability)
		weather_ability.setup_with_weather_ability_data(random_ability)
		weather_abilities.append(weather_ability)
		var field_position:Vector2 = combat_main.plant_field_container.get_field(i).global_position
		weather_ability.global_position = field_position + Vector2.UP * ABILITY_Y_OFFSET
	weathers_abilities_updated.emit()

func apply_weather_actions(plants:Array, combat_main:CombatMain) -> void:
	await _apply_weather_action_to_next_plant(plants, plants.size() - 1, combat_main)

func _apply_weather_action_to_next_plant(plants:Array, plant_index:int, combat_main:CombatMain) -> void:
	if plant_index < 0:
		all_weather_actions_applied.emit()
		return
	var weather_ability:WeatherAbility = weather_abilities[plant_index]
	var player = combat_main.player
	var player_index:int = player.current_field_index
	if plant_index == player_index:
		weather_ability.apply_to_player(player, combat_main)
	else:
		weather_ability.apply_to_plant(plants, plant_index, combat_main)
	await _apply_weather_action_to_next_plant(plants, plant_index - 1, combat_main)
