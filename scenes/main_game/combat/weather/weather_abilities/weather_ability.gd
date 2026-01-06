class_name WeatherAbility
extends Node2D

const ICON_PREFIX := "res://resources/sprites/GUI/icons/weather_ability/icon_%s.png"

@onready var _weather_ability_icon: WeatherAbilityIcon = %WeatherAbilityIcon

var _weather_ability_data:WeatherAbilityData

func setup_with_weather_ability_data(data:WeatherAbilityData) -> void:
	_weather_ability_icon.setup_with_weather_ability_data(data)
	_weather_ability_data = data

func apply_to_player(_player:Player, _combat_main:CombatMain) -> void:
	pass

func apply_to_plant(_plant:Plant, _combat_main:CombatMain) -> void:
	pass
