class_name GUIContractPlaintIcon
extends PanelContainer

@onready var gui_plant_icon: GUIPlantIcon = %GUIPlantIcon
@onready var light_label: Label = %LightLabel
@onready var water_label: Label = %WaterLabel
@onready var count_label: Label = %CountLabel

func update_with_plant_data(plant_data:PlantData, count:int) -> void:
	gui_plant_icon.update_with_plant_data(plant_data)
	light_label.text = str(plant_data.light)
	water_label.text = str(plant_data.water)
	count_label.text = str(count)
