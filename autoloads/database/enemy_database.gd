class_name EnemyDataBase
extends Database

const DIR = "res://data/enemies/"

func roll_enemies(amount:int, appearance_level:int, type:EnemyData.Type) -> Array[EnemyData]:
	var all_enemies := get_all_datas().duplicate()
	all_enemies = all_enemies.filter(func(enemy_data:EnemyData):return enemy_data.type == type)
	all_enemies = all_enemies.filter(func(enemy_data:EnemyData):return enemy_data.appearance_level <= appearance_level)
	all_enemies.shuffle()
	var result:Array[EnemyData] = []
	for i in amount:
		result.append(all_enemies.pop_back().get_duplicate())
	return result

func _get_data_dir() -> String:
	return DIR
