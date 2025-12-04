class_name PlantAbilityData
extends ThingData

@export var active_before_bloom:bool = false
@export var active_after_bloom:bool = false

const PLANT_ABILITY_SCRIPT_PATH := "res://scenes/main_game/plants/abilities/plant_ability_%s.tscn"

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_plant_ability: PlantAbilityData = other as PlantAbilityData
	active_before_bloom = other_plant_ability.active_before_bloom
	active_after_bloom = other_plant_ability.active_after_bloom

func get_duplicate() -> PlantAbilityData:
	var dup:PlantAbilityData = PlantAbilityData.new()
	dup.copy(self)
	return dup

func get_ability_path() -> String:
	var scene_path := PLANT_ABILITY_SCRIPT_PATH % [id]
	return scene_path
	
