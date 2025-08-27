class_name EnemyDatabase
extends Database

const DIR = "res://data/characters/enemy"

func roll_enemies(number_of_enemies:int, chapter:int) -> Array[EnemyData]:
	var available_enemies:Array = _datas.values().duplicate()
	var result:Array[EnemyData] = []
	for i in number_of_enemies:
		var enemy_data:EnemyData = available_enemies.pick_random()
		if !enemy_data.chapters.has(chapter):
			continue
		result.append(enemy_data.get_duplicate())
		available_enemies.erase(enemy_data)
	return result

func _get_data_dir() -> String:
	return DIR
