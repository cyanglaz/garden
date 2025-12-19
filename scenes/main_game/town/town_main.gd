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
	for field:Field in field_container.fields:
		field.field_pressed.connect(_on_field_pressed.bind(field))
	
func _on_town_finished() -> void:
	town_finished.emit()

func _on_field_pressed(field:Field) -> void:
	if field is TavernField:
		_on_tavern_field_pressed(field)
	elif field is ForgeField:
		_on_forge_field_pressed(field)

func _on_tavern_field_pressed(field:TavernField) -> void:
	Events.request_hp_update.emit(field.HP_INCREASE)

func _on_forge_field_pressed(field:ForgeField) -> void:
