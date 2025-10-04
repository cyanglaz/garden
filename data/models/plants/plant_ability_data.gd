class_name PlantAbilityData
extends ThingData

const PLANT_ABILITY_SCRIPT_PATH := "res://scenes/main_game/plants/abilities/plant_ability_%s.tscn"

func get_duplicate() -> PlantAbilityData:
	var dup:PlantAbilityData = PlantAbilityData.new()
	dup.copy(self)
	return dup

func get_ability_path() -> String:
	var scene_path := PLANT_ABILITY_SCRIPT_PATH % [id]
	return scene_path
	
