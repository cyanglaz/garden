class_name ChestMain
extends Node2D

signal card_reward_selected(tool_data:ToolData, from_position:Vector2)
signal skipped()

const CHEST_OPEN_DELAY := 0.4

@onready var gui_chest_main: GUIChestMain = %GUIChestMain
@onready var weather_main: WeatherMain = %WeatherMain
@onready var field: Field = $Field
@onready var chest: Chest = %Chest

func _ready() -> void:
	gui_chest_main.card_reward_selected.connect(_on_card_reward_selected)
	gui_chest_main.skipped.connect(_on_chest_reward_skipped)
	field.field_hovered.connect(_on_field_hovered)
	field.field_pressed.connect(_on_field_pressed)
	weather_main.start(0)

#func _on_chest_selected(index:int) -> void:
	#gui_chest_main.spawn_cards(3, 2, Util.get_node_canvas_position(chest))

func _on_card_reward_selected(tool_data:ToolData, from_position:Vector2) -> void:
	card_reward_selected.emit(tool_data, from_position)

func _on_chest_reward_skipped() -> void:
	skipped.emit()

func _on_field_hovered(hovered:bool) -> void:
	if hovered:
		chest.highlighted = true
	else:
		chest.highlighted = false

func _on_field_pressed() -> void:
	chest.open()
	await Util.create_scaled_timer(CHEST_OPEN_DELAY).timeout
	gui_chest_main.spawn_cards(4, 2, Util.get_node_canvas_position(chest))
