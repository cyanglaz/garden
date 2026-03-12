class_name TrinketDatabase
extends Database

const DIR = "res://data/trinkets"

func roll_trinket(excluded_ids: Array[String]) -> TrinketData:
	var available: Array = get_all_datas().filter(
		func(t: TrinketData) -> bool: return !excluded_ids.has(t.id)
	)
	if available.is_empty():
		return null
	return (available.pick_random() as TrinketData).get_duplicate()

func _get_data_dir() -> String:
	return DIR
