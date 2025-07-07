class_name PlantSeedManager
extends RefCounted

var plant_seeds:Array[PlantData]

var selected_seed_index:int = -1
var selected_seed:PlantData: get = _get_selected_seed

func select_seed(index:int) -> void:
	selected_seed_index = index

func _get_selected_seed() -> PlantData:
	if selected_seed_index < 0:
		return null
	return plant_seeds[selected_seed_index]
