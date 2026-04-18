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

func _get_data_dir() -> String:
	return DIR

func _evaluate_data(resource: Resource) -> void:
	assert(resource is EnchantData)
