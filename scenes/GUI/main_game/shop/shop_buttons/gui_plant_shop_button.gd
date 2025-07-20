class_name GUIPlantShopButton
extends GUIShopButton

@onready var gui_plant_icon: GUIPlantIcon = %GUIPlantIcon

func update_with_plant_data(plant_data:PlantData) -> void:
	gui_plant_icon.update_with_plant_data(plant_data)
	cost = plant_data.cost

func _set_highlighted(val:bool) -> void:
	super._set_highlighted(val)
	if val:
		gui_plant_icon.position.y = -1
	else:
		gui_plant_icon.position.y = 0
	gui_plant_icon.highlighted = val

func _set_sufficient_gold(val:bool) -> void:
	super._set_sufficient_gold(val)
	if val:
		gui_plant_icon.resource_sufficient = true
	else:
		gui_plant_icon.resource_sufficient = false
