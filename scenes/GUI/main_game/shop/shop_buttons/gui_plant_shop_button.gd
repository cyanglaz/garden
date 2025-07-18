class_name GUIPlantShopButton
extends GUIShopButton

@onready var gui_plant_icon: GUIPlantIcon = %GUIPlantIcon

func update_with_plant_data(plant_data:PlantData) -> void:
	gui_plant_icon.update_with_plant_data(plant_data)
	cost_label.text = str(plant_data.cost)
