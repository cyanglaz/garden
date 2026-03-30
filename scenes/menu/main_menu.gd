class_name MainMenu
extends Node2D

@onready var weather_main: WeatherMain = %WeatherMain

func _ready() -> void:
	await weather_main.start(0, CombatData.CombatType.COMMON)
