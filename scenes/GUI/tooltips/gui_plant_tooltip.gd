class_name GUIPlantTooltip
extends GUITooltip

@onready var _gui_plant_description: GUIPlantDescription = %GUIPlantDescription

func _update_with_tooltip_request() -> void:
	var plant_data:PlantData = _tooltip_request.data as PlantData
	_gui_plant_description.update_with_plant_data(plant_data)
