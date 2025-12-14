class_name PlantAbilityData
extends ThingData

const PLANT_ABILITY_SCRIPT_PATH := "res://scenes/main_game/plants/abilities/plant_ability_%s.tscn"

@export var cooldown:int = 0

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_plant_ability_data := other as PlantAbilityData
	cooldown = other_plant_ability_data.cooldown

func get_duplicate() -> PlantAbilityData:
	var dup:PlantAbilityData = PlantAbilityData.new()
	dup.copy(self)
	return dup

func get_ability_path() -> String:
	var scene_path := PLANT_ABILITY_SCRIPT_PATH % [id]
	return scene_path
	
