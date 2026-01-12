class_name WeatherAbilityAnimationContainer
extends Node2D

const ANIMATION_SCENE_PREFIX := "res://scenes/main_game/combat/weather/weather_abilities/animations/%s.tscn"

func run_animation(weather_ability:WeatherAbility, target_position:Vector2, blocked_by_player:bool) -> void:
	var animation_path:String = ANIMATION_SCENE_PREFIX % weather_ability.weather_ability_data.id
	if not ResourceLoader.exists(animation_path):
		return
	var animation_scene:PackedScene = load(animation_path)
	var animation_instance:WeatherAbilityAnimation = animation_scene.instantiate()
	add_child(animation_instance)
	await animation_instance.start(weather_ability.global_position, target_position, blocked_by_player)
