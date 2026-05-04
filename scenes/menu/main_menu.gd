class_name MainMenu
extends Node2D

@onready var weather_main: WeatherMain = %WeatherMain
@onready var gui_main_menu: GUIMainMenu = $GUIMainMenu

func _ready() -> void:
	weather_main.start(0, CombatData.CombatType.COMMON)
	gui_main_menu.animate_buttons_slide_in()
