class_name GUIShopMain
extends Control

signal plant_shop_button_pressed(plant_data:PlantData)

const PLANT_SHOP_BUTTON_SCENE := preload("res://scenes/GUI/main_game/shop/shop_buttons/gui_plant_shop_button.tscn")
# const TOOL_SHOP_BUTTON_SCENE := preload("res://scenes/GUI/main_game/shop/shop_buttons/gui_tool_shop_button.tscn")

@onready var seed_container: HBoxContainer = %SeedContainer
@onready var tool_container: HBoxContainer = %ToolContainer

func _ready() -> void:
	populate_shop(3, 0)

func populate_shop(number_of_plants:int, number_of_tools:int) -> void:
	_populate_plants(number_of_plants)

func _populate_plants(number_of_plants) -> void:
	var plants := MainDatabase.plant_database.roll_plants(number_of_plants)
	for plant_data:PlantData in plants:	
		var plant_shop_button := PLANT_SHOP_BUTTON_SCENE.instantiate()
		seed_container.add_child(plant_shop_button)
		plant_shop_button.update_with_plant_data(plant_data)
		plant_shop_button.action_evoked.connect(_on_plant_shop_button_action_evoked.bind(plant_data))

func _on_plant_shop_button_action_evoked(plant_data:PlantData) -> void:
	plant_shop_button_pressed.emit(plant_data)
