class_name TrinketDatabase
extends Database

const DIR = "res://data/trinkets"
const RARITY_WEIGHTS := {0: 6, 1: 3, 2: 1}

func roll_trinkets(count: int) -> Array[TrinketData]:
	var available: Array = get_all_datas().duplicate()
	var result: Array[TrinketData] = []
	for i in min(count, available.size()):
		var pool: Array = []
		for t: TrinketData in available:
			for _w in RARITY_WEIGHTS.get(t.rarity, 1):
				pool.append(t)
		var chosen: TrinketData = pool.pick_random()
		result.append(chosen.get_duplicate())
		available.erase(chosen)
	return result

func roll_trinket(excluded_ids: Array[String]) -> TrinketData:
	var available: Array = get_all_datas().filter(
		func(t: TrinketData) -> bool: return !excluded_ids.has(t.id)
	)
	if available.is_empty():
		return null
	return (available.pick_random() as TrinketData).get_duplicate()

func _get_data_dir() -> String:
	return DIR
