class_name WeatherAbilityContainer
extends Node2D

# Ability summon logic
const SPECIAL_ABILITY_TURN_THRESHOLD := 3
const BASE_SPECIAL_ABILITY_TURN_CHANCE := 0.7
const BASE_SPECIAL_ABILITY_TURN_CHANCE_INCREASE := 0.1
const BASE_SPECIAL_ABILITY_TURN_CHANCE_DECREASE := 0.2
const SPECIAL_ABILITY_LEVEL_UP_TURNS := 2
const BASE_SPECIAL_ABILITY_CHANCE := 0.3
const BASE_REGULAR_ABILITY_CHANCE_FOR_EACH_FIELD := 0.8
const CHANCE_FOR_EMPTY_FIELDS := 0.5

const ABILITY_Y_OFFSET := 70

signal weathers_abilities_updated()
signal all_weather_actions_applied()

const WEATHER_ABILITIES_SCENE_PREFIX := "res://scenes/main_game/combat/weather/weather_abilities/weather_ability_%s.tscn"

var weather_abilities:Array
var special_ability_turn_chance:float = BASE_SPECIAL_ABILITY_TURN_CHANCE
var regular_ability_chance_for_each_field:float = BASE_REGULAR_ABILITY_CHANCE_FOR_EACH_FIELD
var special_ability_level_up_turns_count := 0
var special_ability_level := 0

func generate_next_weather_abilities(weather_data:WeatherData, combat_main:CombatMain, turn_index:int) -> void:
	clear_all_weather_abilities()

	var field_indices := range(combat_main.plant_field_container.plants.size())
	var fields_have_abilities:Array
	var abilities:Array[WeatherAbilityData]
	# It's a all special ability turn
	if turn_index >= SPECIAL_ABILITY_TURN_THRESHOLD:
		var roll:float = randf_range(0, 1)
		if roll < special_ability_turn_chance:
			if special_ability_level_up_turns_count >= SPECIAL_ABILITY_LEVEL_UP_TURNS:
				special_ability_level += 1
				special_ability_level_up_turns_count = 0
			for i in combat_main.plant_field_container.plants.size():
				var random_ability:WeatherAbilityData = Util.unweighted_roll(weather_data.special_abilities, 1)[0]
				abilities.append(random_ability)
			special_ability_turn_chance -= BASE_SPECIAL_ABILITY_TURN_CHANCE_DECREASE
			fields_have_abilities = field_indices
			special_ability_level_up_turns_count += 1
		else:
			regular_ability_chance_for_each_field += BASE_SPECIAL_ABILITY_TURN_CHANCE_INCREASE
	
	if fields_have_abilities.is_empty():
		# Regular turns
		for i in combat_main.plant_field_container.plants.size():
			var roll:float = randf_range(0, 1)
			if roll < BASE_SPECIAL_ABILITY_CHANCE:
				var random_special_ability:WeatherAbilityData = Util.unweighted_roll(weather_data.special_abilities, 1)[0]
				abilities.append(random_special_ability)
			else:
				var random_regular_ability:WeatherAbilityData = Util.unweighted_roll(weather_data.regular_abilities, 1)[0]
				abilities.append(random_regular_ability)
		
		# Roll for empty fields
		for i in combat_main.plant_field_container.plants.size():
			if abilities.size() == 1:
				# Need at least one ability
				break
			var roll:float = randf_range(0, 1)
			if roll < CHANCE_FOR_EMPTY_FIELDS:
				abilities.pop_back()
		fields_have_abilities = Util.unweighted_roll(field_indices, abilities.size()).duplicate()
	for i in fields_have_abilities.size():
		var ability:WeatherAbilityData = abilities[i]
		var is_special_ability:bool = ability in weather_data.special_abilities
		print("is_special_ability: ", is_special_ability)
		var field_index:int = fields_have_abilities[i]
		var weather_ability_scene:PackedScene = load(WEATHER_ABILITIES_SCENE_PREFIX % ability.id)
		var weather_ability:WeatherAbility = weather_ability_scene.instantiate()
		if is_special_ability:
			weather_ability.level = special_ability_level
		weather_ability.field_index = field_index
		add_child(weather_ability)
		weather_ability.setup_with_weather_ability_data(ability)
		weather_abilities.append(weather_ability)
		var field_position:Vector2 = combat_main.plant_field_container.get_field(field_index).global_position
		weather_ability.global_position = field_position + Vector2.UP * ABILITY_Y_OFFSET

	weathers_abilities_updated.emit()

func apply_weather_actions(plants:Array, combat_main:CombatMain) -> void:
	await _apply_weather_action_to_next_plant(plants, plants.size() - 1, combat_main)

func clear_all_weather_abilities() -> void:
	Util.remove_all_children(self)
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
	if plant_index == player_index:
		await weather_ability.apply_to_player(player, combat_main)
	else:
		await weather_ability.apply_to_plant(plants, plant_index, combat_main)
	await _apply_weather_action_to_next_plant(plants, plant_index - 1, combat_main)
