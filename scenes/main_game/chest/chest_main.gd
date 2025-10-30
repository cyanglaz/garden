class_name ChestMain
extends Node2D

const CHEST_OPEN_DELAY := 0.4

@onready var gui_chest_main: GUIChestMain = %GUIChestMain
@onready var chest_container: ChestContainer = %ChestContainer

func _ready() -> void:
	update_with_number_of_chests(3)
	chest_container.chest_selected.connect(_on_chest_selected)

func update_with_number_of_chests(number_of_chests:int) -> void:
	chest_container.update_with_number_of_chests(number_of_chests)

func _on_chest_selected(index:int) -> void:
	var chest:Chest = chest_container.get_chest(index)
	await Util.create_scaled_timer(CHEST_OPEN_DELAY).timeout
	gui_chest_main.spawn_cards(3, 2, Util.get_node_canvas_position(chest))
