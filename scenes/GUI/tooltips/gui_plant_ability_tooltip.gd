class_name GUIPlantAbilityTooltip
extends GUITooltip

@onready var gui_plant_ability_description: GUIPlantAbilityDescription = %GUIPlantAbilityDescription

func _update_with_tooltip_request() -> void:
	var plant_ability_data:PlantAbilityData = _tooltip_request.data as PlantAbilityData
	var stack:int = _tooltip_request.additional_data.get("stack", 0)
	gui_plant_ability_description.update_with_plant_ability_data(plant_ability_data, stack)
