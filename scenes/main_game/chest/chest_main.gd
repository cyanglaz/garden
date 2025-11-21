class_name ChestMain
extends Node2D

signal card_reward_selected(tool_data:ToolData, from_position:Vector2)
signal skipped()

@onready var gui_chest_main: GUIChestMain = %GUIChestMain
@onready var weather_main: WeatherMain = %WeatherMain
@onready var chest_field: ChestField = %ChestField

func _ready() -> void:
	gui_chest_main.card_reward_selected.connect(_on_card_reward_selected)
	gui_chest_main.skipped.connect(_on_chest_reward_skipped)
	chest_field.chest_opened.connect(_on_chest_opened)
	weather_main.start(0)

func _on_card_reward_selected(tool_data:ToolData, from_position:Vector2) -> void:
	card_reward_selected.emit(tool_data, from_position)

func _on_chest_reward_skipped() -> void:
	skipped.emit()

func _on_chest_opened(chest: Chest) -> void:
	gui_chest_main.spawn_cards(4, 2, Util.get_node_canvas_position(chest))
