class_name BossDatabase
extends Database

const DIR = "res://data/bosses"

func roll_bosses(number_of_bosses:int) -> Array[BossData]:
	var available_bosses:Array = _get_all_resources(_datas, "").values().duplicate()
	var result:Array[BossData] = []
	for i in number_of_bosses:
		var boss_data = available_bosses.pick_random()
		result.append(boss_data.get_duplicate())
		available_bosses.erase(boss_data)
	return result

func _get_data_dir() -> String:
	return DIR
