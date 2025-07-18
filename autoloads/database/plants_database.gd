class_name PlantDatabase
extends Database

const DIR = "res://data/plants"

func roll_plants(number_of_plants:int) -> Array[PlantData]:
	var available_plants:Array = _datas.values().duplicate()
	var result:Array[PlantData] = []
	for i in number_of_plants:
		var plant_data:PlantData = available_plants.pick_random()
		result.append(plant_data.get_duplicate())
		available_plants.erase(plant_data)
	return result

func _get_data_dir() -> String:
	return DIR
