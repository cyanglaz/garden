class_name EnchantDatabase
extends Database

const DIR = "res://data/enchants"
const RARITY_WEIGHTS := {0: 6, 1: 3, 2: 1}

func roll_purchasable_enchants(count: int) -> Array[EnchantData]:
	var available: Array = _get_all_resources(_datas, "purchasable").values().duplicate()
	var result: Array[EnchantData] = []
	for i in min(count, available.size()):
		var weights: Array[int] = []
		for e: EnchantData in available:
			weights.append(RARITY_WEIGHTS.get(e.rarity, 1))
		var chosen: EnchantData = Util.weighted_roll(available, weights)
		result.append(chosen.get_duplicate())
		available.erase(chosen)
	return result

func roll_shop_enchants() -> Array[EnchantData]:
	var available: Array = _get_all_resources(_datas, "purchasable").values().filter(
		func(e: EnchantData) -> bool: return e.rarity < 2
	)
	return _select_shop_enchants(available)

static func _select_shop_enchants(available: Array) -> Array[EnchantData]:
	var available_copy: Array = available.duplicate()
	var common_pool: Array = available_copy.filter(func(e: EnchantData) -> bool: return e.rarity == 0)
	var uncommon_pool: Array = available_copy.filter(func(e: EnchantData) -> bool: return e.rarity == 1)
	var result: Array[EnchantData] = []

	if common_pool.size() >= 2 and uncommon_pool.size() >= 1:
		for _i in 2:
			var chosen_common: EnchantData = common_pool.pick_random()
			result.append(chosen_common.get_duplicate())
			common_pool.erase(chosen_common)
		var chosen_uncommon: EnchantData = uncommon_pool.pick_random()
		result.append(chosen_uncommon.get_duplicate())
	else:
		for _i in min(3, available_copy.size()):
			var chosen: EnchantData = available_copy.pick_random()
			result.append(chosen.get_duplicate())
			available_copy.erase(chosen)

	return result

func _get_data_dir() -> String:
	return DIR

func _evaluate_data(resource: Resource) -> void:
	assert(resource is EnchantData)
