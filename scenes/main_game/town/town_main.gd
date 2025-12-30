class_name TownMain
extends Node2D

signal town_finished()
signal forge_finished(tool_data:ToolData, front_card_data:ToolData, back_card_data:ToolData)
signal forged_card_pressed(tool_data:ToolData, forged_card_global_position:Vector2)
const TAVERN_WAIT_TIME := 1.0

@onready var gui_town_main: GUITownMain = %GUITownMain
@onready var weather_main: WeatherMain = %WeatherMain
@onready var field_container: FieldContainer = %FieldContainer

var _interacted := false
var _started := false

func _ready() -> void:
	field_container.setup_fields()
	await weather_main.start(0)
	_started = true
	for field:Field in field_container.fields:
		field.field_pressed.connect(_on_field_pressed.bind(field))
	gui_town_main.forge_finished.connect(_on_forge_finished)
	gui_town_main.forged_card_pressed.connect(_on_forged_card_pressed)
	
func setup_with_card_pool(card_pool:Array[ToolData]) -> void:
	gui_town_main.setup_with_card_pool(card_pool)

func _on_field_pressed(field:Field) -> void:
	if _interacted || !_started:
		return
	if field is TavernField:
		_on_tavern_field_pressed(field)
	elif field is ForgeField:
		_on_forge_field_pressed(field)

func _on_tavern_field_pressed(field:TavernField) -> void:
	_disable_all_field_presses()
	_interacted = true
	field.interacted = true
	await weather_main.night_fall()
	Events.request_hp_update.emit(field.HP_INCREASE)
	await Util.create_scaled_timer(TAVERN_WAIT_TIME).timeout
	town_finished.emit()

func _on_forge_field_pressed(_field:ForgeField) -> void:
	gui_town_main.show_forge_main()

func _on_forge_finished(tool_data:ToolData, front_card_data:ToolData, back_card_data:ToolData) -> void:
	forge_finished.emit(tool_data, front_card_data, back_card_data)

func _on_forged_card_pressed(tool_data:ToolData, forged_card_global_position:Vector2) -> void:
	forged_card_pressed.emit(tool_data, forged_card_global_position)

func _disable_all_field_presses() -> void:
	for field:Field in field_container.fields:
		field.press_enabled = false
