class_name GUIPlantTooltip
extends GUITooltip

@onready var _gui_plant_description: GUIPlantDescription = %GUIPlantDescription

var library_mode := false

func _update_with_data() -> void:
	var plant_data:PlantData = _data as PlantData
	_gui_plant_description.update_with_plant_data(plant_data)