class_name PlantData
extends ThingData

const PLANT_SCENE_PATH_PREFIX:String = "res://scenes/plants/plant_"

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
}

@export var light:int
@export var water:int
@export var gold:int
@export var rarity:Rarity

func copy(other:ThingData) -> void:
	var other_plant: PlantData = other as PlantData
	light = other_plant.light
	water = other_plant.water
	gold = other_plant.gold
	rarity = other_plant.rarity

func get_duplicate() -> PlantData:
	var dup:PlantData = PlantData.new()
	dup.copy(self)
	return dup

func get_plant() -> Plant:
	var path:String = PLANT_SCENE_PATH_PREFIX + id + ".tscn"
	var scene:PackedScene = load(path)
	var plant:Plant = scene.instantiate()
	plant.data = self
	return plant

func get_display_description() -> String:
	var formatted_description := description
	formatted_description = _formate_references(formatted_description, data, func(_reference_id:String) -> bool:
		return false
	)
	return formatted_description
