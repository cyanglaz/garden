class_name PlantAbilityIcon
extends GUIIcon

const ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_"

func update_with_plant_ability_id(plant_ability_id:String) -> void:
	texture = load(ICON_PATH + plant_ability_id + ".png")
