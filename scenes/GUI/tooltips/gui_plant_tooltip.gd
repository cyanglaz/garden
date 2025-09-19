class_name GUIPlantTooltip
extends GUITooltip

@onready var _gui_plant_description: GUIPlantDescription = %GUIPlantDescription

var library_mode := false

func update_with_plant_data(plant_data:PlantData) -> void:
	_gui_plant_description.update_with_plant_data(plant_data)
