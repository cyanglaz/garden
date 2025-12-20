class_name TownMain
extends Node2D

signal town_finished()
const TAVERN_WAIT_TIME := 1.0

@onready var gui_town_main: GUITownMain = %GUITownMain
@onready var weather_main: WeatherMain = %WeatherMain
@onready var field_container: FieldContainer = %FieldContainer

var _interacted := false

func _ready() -> void:
	field_container.setup_fields()
	weather_main.start(0)
	for field:Field in field_container.fields:
		field.field_pressed.connect(_on_field_pressed.bind(field))

func _on_field_pressed(field:Field) -> void:
	if _interacted:
		return
	_disable_all_field_presses()
	_interacted = true
	if field is TavernField:
		_on_tavern_field_pressed(field)
	elif field is ForgeField:
		_on_forge_field_pressed(field)

func _on_tavern_field_pressed(field:TavernField) -> void:
	field.interacted = true
	await weather_main.night_fall()
	Events.request_hp_update.emit(field.HP_INCREASE)
	await Util.create_scaled_timer(TAVERN_WAIT_TIME).timeout
	town_finished.emit()

func _on_forge_field_pressed(field:ForgeField) -> void:
	pass

func _disable_all_field_presses() -> void:
	for field:Field in field_container.fields:
		field.press_enabled = false
