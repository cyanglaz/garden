class_name GUIPlantCard
extends HBoxContainer

signal plant_button_action_evoked()

@onready var _gui_plant_button: GUIPlantButton = %GUIPlantButton

func _ready() -> void:
	_gui_plant_button.action_evoked.connect(func(): plant_button_action_evoked.emit())

func update_with_plant_data(plant_data:PlantData) -> void:
	_gui_plant_button.update_with_plant_data(plant_data)
