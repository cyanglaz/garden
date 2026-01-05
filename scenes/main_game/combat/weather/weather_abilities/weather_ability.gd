class_name WeatherAbility
extends Node2D

const ICON_PREFIX := "res://resources/sprites/GUI/icons/weather_ability/icon_%s.png"

@onready var gui_icon: GUIIcon = %GUIIcon

var weather_ability_data:WeatherAbilityData

func setup_with_weather_ability_data(data:WeatherAbilityData) -> void:
	self.weather_ability_data = data
	gui_icon.texture = load(ICON_PREFIX % weather_ability_data.id)

func apply_to_player(_player:Player, _combat_main:CombatMain) -> void:
	pass

func apply_to_plant(_plant:Plant, _combat_main:CombatMain) -> void:
	pass
