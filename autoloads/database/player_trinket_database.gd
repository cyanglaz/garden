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
		var weights: Array[int] = []
		for t: TrinketData in available:
			weights.append(RARITY_WEIGHTS.get(t.rarity, 1))
		var chosen: TrinketData = Util.weighted_roll(available, weights)
		result.append(chosen.get_duplicate())
		available.erase(chosen)
	return result

func roll_shop_trinkets(excluded_ids: Array[String] = []) -> Array[TrinketData]:
	var available: Array = get_all_datas().filter(
		func(t: TrinketData) -> bool: return !excluded_ids.has(t.id) and t.rarity < 2
	)
	return _select_shop_trinkets(available)

static func _select_shop_trinkets(available: Array) -> Array[TrinketData]:
	var common_pool: Array = available.filter(func(t: TrinketData) -> bool: return t.rarity == 0)
	var uncommon_pool: Array = available.filter(func(t: TrinketData) -> bool: return t.rarity == 1)
	var result: Array[TrinketData] = []

	if common_pool.size() >= 2 and uncommon_pool.size() >= 1:
		for _i in 2:
			var chosen: TrinketData = common_pool.pick_random()
			result.append(chosen.get_duplicate())
			common_pool.erase(chosen)
		var chosen: TrinketData = uncommon_pool.pick_random()
		result.append(chosen.get_duplicate())
	else:
		for _i in min(3, available.size()):
			var chosen: TrinketData = available.pick_random()
			result.append(chosen.get_duplicate())
			available.erase(chosen)

	return result

func _get_data_dir() -> String:
	return DIR
