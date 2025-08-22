class_name PlantData
extends ThingData

const PLANT_SCENE_PATH_PREFIX:String = "res://scenes/main_game/plants/plant_"

const COSTS := {
	0: 12,
	1: 18,
	2: 24
}

@export var light:int
@export var water:int
@export var points:int
@export var rarity:int

var cost:int: get = _get_cost

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_plant: PlantData = other as PlantData
	light = other_plant.light
	water = other_plant.water
	points = other_plant.points
	rarity = other_plant.rarity

func get_duplicate() -> PlantData:
	var dup:PlantData = PlantData.new()
	dup.copy(self)
	return dup

func _get_cost() -> int:
	return COSTS[rarity]
			
