class_name ChestMain
extends Node2D

signal trinket_reward_selected(trinket_data: TrinketData)
signal skipped()

@onready var gui_chest_main: GUIChestMain = %GUIChestMain
@onready var weather_main: WeatherMain = %WeatherMain
@onready var chest_field: ChestField = %ChestField

var _trinket_data: TrinketData = null

func _ready() -> void:
	gui_chest_main.trinket_reward_selected.connect(_on_trinket_reward_selected)
	gui_chest_main.skipped.connect(_on_chest_reward_skipped)
	chest_field.chest_opened.connect(_on_chest_opened)
	weather_main.start(0, CombatData.CombatType.COMMON)

func start(trinket_data: TrinketData) -> void:
	_trinket_data = trinket_data

func _on_trinket_reward_selected(trinket_data: TrinketData) -> void:
	trinket_reward_selected.emit(trinket_data)

func _on_chest_reward_skipped() -> void:
	skipped.emit()

func _on_chest_opened(chest: Chest) -> void:
	gui_chest_main.spawn_trinket(_trinket_data, Util.get_node_canvas_position(chest))
