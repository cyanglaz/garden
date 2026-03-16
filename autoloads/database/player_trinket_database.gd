class_name TrinketDatabase
extends Database

const DIR = "res://data/trinkets"
const RARITY_WEIGHTS := {0: 6, 1: 3, 2: 1}

func roll_trinkets(count: int, excluded_ids: Array[String] = []) -> Array[TrinketData]:
	var available: Array = get_all_datas().filter(
		func(t: TrinketData) -> bool: return !excluded_ids.has(t.id)
	).duplicate()
	var result: Array[TrinketData] = []
	for i in min(count, available.size()):
		var weights: Array = available.map(func(t: TrinketData) -> int: return RARITY_WEIGHTS.get(t.rarity, 1))
		var chosen: TrinketData = Util.weighted_roll(available, weights)
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
