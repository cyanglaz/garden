class_name GUIPlantAbilityTooltip
extends GUITooltip

@onready var gui_plant_ability_description: GUIPlantAbilityDescription = %GUIPlantAbilityDescription

func _update_with_data() -> void:
	var plant_ability_data:PlantAbilityData = _data as PlantAbilityData
	gui_plant_ability_description.update_with_plant_ability_data(plant_ability_data, true)
