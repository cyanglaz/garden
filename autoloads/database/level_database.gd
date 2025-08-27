class_name LevelDatabase
extends Database

const DIR = "res://data/levels"

func roll_levels(number_of_levels:int, chapter:int, level:int) -> Array[LevelData]:
	var available_levels:Array = _datas.values().duplicate()
	var result:Array[LevelData] = []
	for i in number_of_levels:
		var level_data:LevelData = available_levels.pick_random()
		var appearance_string = str(chapter, level)
		if !level_data.appearance.has(appearance_string):
			continue
		result.append(level_data.get_duplicate())
		available_levels.erase(level_data)
	return result

func _get_data_dir() -> String:
	return DIR
