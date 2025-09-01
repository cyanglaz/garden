class_name LevelDatabase
extends Database

const DIR = "res://data/levels"

func roll_levels(number_of_levels:int, chapter:int) -> Array[LevelData]:
	var available_levels:Array = _get_all_resources(_datas, "").values().duplicate()
	var result:Array[LevelData] = []
	for i in number_of_levels:
		var appearance_string = str(chapter, i)
		var matching_levels := available_levels.filter(func(check_level:LevelData) -> bool: return check_level.appearance.has(appearance_string))
		var level_data = matching_levels.pick_random()
		result.append(level_data.get_duplicate())
		available_levels.erase(level_data)
	return result

func _get_data_dir() -> String:
	return DIR
