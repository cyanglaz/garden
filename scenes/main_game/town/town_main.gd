class_name TownMain
extends Node2D

signal town_finished()
const TAVERN_WAIT_TIME := 1.0

@onready var gui_town_main: GUITownMain = %GUITownMain
@onready var weather_main: WeatherMain = %WeatherMain
@onready var field_container: FieldContainer = %FieldContainer

var _interacted := false
var _started := false

func _ready() -> void:
	field_container.setup_fields()
	await weather_main.start(0, CombatData.CombatType.COMMON)
	_started = true
	for field:Field in field_container.fields:
		field.field_pressed.connect(_on_field_pressed.bind(field))
	gui_town_main.enchant_finished.connect(_on_enchant_finished)
	gui_town_main.enchant_card_pressed.connect(_on_enchant_card_pressed)
	
func setup_with_card_pool(card_pool:Array[ToolData]) -> void:
	var rolls := MainDatabase.enchant_database.roll_purchasable_enchants(1)
	assert(rolls.size() > 0, "No purchasable enchants found")
	var enchant_data:EnchantData = rolls[0]
	gui_town_main.setup_with_card_pool(card_pool, enchant_data)

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
	Events.request_hp_update.emit(field.HP_INCREASE, ActionData.OperatorType.INCREASE)
	await Util.create_scaled_timer(TAVERN_WAIT_TIME).timeout
	town_finished.emit()

func _on_forge_field_pressed(_field:ForgeField) -> void:
	gui_town_main.show_enchant_main()

func _on_enchant_finished(old_tool_data:ToolData) -> void:
	Events.request_remove_card_from_deck.emit(old_tool_data)

func _on_enchant_card_pressed(tool_data:ToolData, enchant_card_global_position:Vector2) -> void:
	Events.request_add_card_to_deck.emit(tool_data, enchant_card_global_position)
	await Util.await_for_tiny_time()
	town_finished.emit()

func _disable_all_field_presses() -> void:
	for field:Field in field_container.fields:
		field.press_enabled = false
