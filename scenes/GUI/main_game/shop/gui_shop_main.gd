class_name GUIShopMain
extends Control

signal plant_shop_button_pressed(plant_data:PlantData)
signal tool_shop_button_pressed(tool_data:ToolData)

const PLANT_SHOP_BUTTON_SCENE := preload("res://scenes/GUI/main_game/shop/shop_buttons/gui_plant_shop_button.tscn")
const TOOL_SHOP_BUTTON_SCENE := preload("res://scenes/GUI/main_game/shop/shop_buttons/gui_tool_shop_button.tscn")

@onready var seed_container: GridContainer = %SeedContainer
@onready var tool_container: HBoxContainer = %ToolContainer

func _ready() -> void:
	populate_shop(3, 4)

func populate_shop(number_of_plants:int, number_of_tools:int) -> void:
	_populate_plants(number_of_plants)
	_populate_tools(number_of_tools)

func _populate_plants(number_of_plants) -> void:
	var plants := MainDatabase.plant_database.roll_plants(number_of_plants)
	for plant_data:PlantData in plants:	
		var plant_shop_button:GUIPlantShopButton = PLANT_SHOP_BUTTON_SCENE.instantiate()
		seed_container.add_child(plant_shop_button)
		plant_shop_button.update_with_plant_data(plant_data)
		plant_shop_button.action_evoked.connect(_on_plant_shop_button_action_evoked.bind(plant_data))

func _populate_tools(number_of_tools) -> void:
	var tools := MainDatabase.tool_database.roll_tools(number_of_tools)
	for tool_data:ToolData in tools:
		var tool_shop_button:GUIToolShopButton  = TOOL_SHOP_BUTTON_SCENE.instantiate()
		tool_container.add_child(tool_shop_button)
		tool_shop_button.update_with_tool_data(tool_data)
		tool_shop_button.action_evoked.connect(_on_tool_shop_button_action_evoked.bind(tool_data))

func _on_plant_shop_button_action_evoked(plant_data:PlantData) -> void:
	plant_shop_button_pressed.emit(plant_data)

func _on_tool_shop_button_action_evoked(tool_data:ToolData) -> void:
	tool_shop_button_pressed.emit(tool_data)
