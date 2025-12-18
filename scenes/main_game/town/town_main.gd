class_name TownMain
extends Node2D

signal town_finished()

@onready var gui_town_main: GUITownMain = %GUITownMain
@onready var weather_main: WeatherMain = %WeatherMain
@onready var field_container: FieldContainer = %FieldContainer

func _ready() -> void:
	field_container.setup_fields()
	gui_town_main.town_finished.connect(_on_town_finished)
	weather_main.start(0)

func _on_town_finished() -> void:
	town_finished.emit()
