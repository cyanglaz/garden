class_name ContractGenerator
extends RefCounted

const MAX_REROLL_PLANTS_COUNT := 100
const TOTAL_COMMON_CONTRACTS_TO_GENERATE_PER_CHAPTER := 4
const TOTAL_ELITE_CONTRACTS_TO_GENERATE_PER_CHAPTER := 2
const TOTAL_BOSS_CONTRACTS_TO_GENERATE_PER_CHAPTER := 1

const BASE_NUMBER_OF_PLANTS_DICE := {
	3: 0.15,
	4: 0.35,
	5: 0.35,
	6: 0.15,
}

const NUMBER_OF_PLANTS_TYPE_DICE := {
	1: 0.15,
	2: 0.7,
	3: 0.15
}


const TOP_PLANT_DIFFICULTY_FOR_TYPE := {
	ContractData.ContractType.COMMON: 0,
	ContractData.ContractType.ELITE: 1,
	ContractData.ContractType.BOSS: 2,
}

const BASE_REWARD_VALUE_FOR_TYPE := {
	ContractData.ContractType.COMMON: 6,
	ContractData.ContractType.ELITE: 12,
	ContractData.ContractType.BOSS: 26,
}

const BASE_BOOSTER_PACK_TYPE_FOR_TYPE := {
	ContractData.ContractType.COMMON: ContractData.BoosterPackType.COMMON,
	ContractData.ContractType.ELITE: ContractData.BoosterPackType.RARE,
	ContractData.ContractType.BOSS: ContractData.BoosterPackType.EPIC,
}

const REWARD_VALUE_CHAPTER_MULTIPLIER := 2
const RATING_REWARD_CHANCE := 0.1
const RATING_REWARD_RATE := 0.3

const BASE_GRACE_PERIOD := 4
const BASE_PENALTY_RATE_FOR_TYPE := {
	ContractData.ContractType.COMMON: 1,
	ContractData.ContractType.ELITE: 2,
	ContractData.ContractType.BOSS: 2,
}

var _common_contracts:Array[ContractData] = []
var _elite_contracts:Array[ContractData] = []
var _boss_contract:ContractData = null
var _all_available_plants:Array[PlantData] = []

func generate_contracts(chapter:int) -> void:
	_all_available_plants = MainDatabase.plants_database.get_all_datas().filter(func(plant:PlantData) -> bool: return plant.chapters.has(chapter))
	_common_contracts = _generate_contracts(chapter, ContractData.ContractType.COMMON, TOTAL_COMMON_CONTRACTS_TO_GENERATE_PER_CHAPTER)
	_elite_contracts = _generate_contracts(chapter, ContractData.ContractType.ELITE, TOTAL_ELITE_CONTRACTS_TO_GENERATE_PER_CHAPTER)
	_boss_contract = _generate_contracts(chapter, ContractData.ContractType.BOSS, 1).front()

func _generate_contracts(chapter:int, contract_type:ContractData.ContractType, count:int) -> Array[ContractData]:
	var contracts:Array[ContractData] = []
	for i in count:
		var contract:ContractData = ContractData.new()
		contract.contract_type = contract_type
		contract.grace_period = BASE_GRACE_PERIOD + chapter
		contract.penalty_rate = BASE_PENALTY_RATE_FOR_TYPE[contract_type] + chapter

		# Plants
		contract.plants = _roll_plants(chapter, contract_type)

		# Gold and rating rewards
		var reward_value = BASE_REWARD_VALUE_FOR_TYPE[contract_type] + chapter * REWARD_VALUE_CHAPTER_MULTIPLIER
		var has_rating_reward = randf() < RATING_REWARD_CHANCE
		if has_rating_reward:
			contract.reward_rating = ceili((reward_value/2) * RATING_REWARD_RATE)
			contract.reward_gold = floori(reward_value/2)
		else:
			contract.reward_gold = reward_value

		# Booster pack rewards
		contract.reward_booster_pack_type = BASE_BOOSTER_PACK_TYPE_FOR_TYPE[contract_type]

		contracts.append(contract)
	return contracts

func _roll_number_of_plants(chapter:int) -> int:
	var values := BASE_NUMBER_OF_PLANTS_DICE.keys()
	var weights := BASE_NUMBER_OF_PLANTS_DICE.values()
	return Util.weighted_roll(values, weights) + chapter

func _roll_number_of_plants_type(chapter:int) -> int:
	var values := NUMBER_OF_PLANTS_TYPE_DICE.keys()
	var weights := NUMBER_OF_PLANTS_TYPE_DICE.values()
	return Util.weighted_roll(values, weights) + chapter

func _roll_plants(chapter:int, contract_type:ContractData.ContractType) -> Array[PlantData]:
	var top_plant_difficulty:int = TOP_PLANT_DIFFICULTY_FOR_TYPE[contract_type] + chapter
	var pick_result:Array[PlantData] = []
	for i in MAX_REROLL_PLANTS_COUNT:
		var roll_once_result := _roll_plants_once(chapter, top_plant_difficulty)
		# Ensure the plant combinations are unique in the same contract type
		var list_to_check:Array[ContractData]
		match contract_type:
			ContractData.ContractType.COMMON:
				list_to_check = _common_contracts.duplicate()
			ContractData.ContractType.ELITE:
				list_to_check = _elite_contracts.duplicate()
			ContractData.ContractType.BOSS:
				list_to_check = []

		pick_result = roll_once_result
		for contract:ContractData in list_to_check:
			if !contract.has_same_plant_types(roll_once_result):
				break
	return pick_result

func _roll_plants_once(chapter:int, top_plant_difficulty:int) -> Array[PlantData]:
	var number_of_plants := _roll_number_of_plants(chapter)
	var number_of_plants_type := _roll_number_of_plants_type(chapter)

	# Find the plants match the top plant difficulty
	var primary_plants:Array[PlantData] = _all_available_plants.filter(
		func(plant:PlantData) -> bool: return plant.difficulty == top_plant_difficulty
	)
	# Find the plants match the second top plant difficulty
	var secondary_plants:Array[PlantData] = _all_available_plants.filter(
		func(plant:PlantData) -> bool: return plant.difficulty == top_plant_difficulty - 1
	)

	var selected_plant_types:Array[PlantData] = []

	# Pick the primary plant
	var primary_pick:PlantData = primary_plants.pick_random()
	primary_plants.erase(primary_pick)
	var rest_available_plants:Array[PlantData] = primary_plants + secondary_plants
	for i in number_of_plants_type - 1:
		var pick:PlantData = rest_available_plants.pick_random()
		rest_available_plants.erase(pick)
		selected_plant_types.append(pick)

	for plant_data:PlantData in selected_plant_types:
		_all_available_plants.erase(plant_data)

	var result:Array[PlantData] = []
	# Pick each selection at least once
	for plant_data:PlantData in selected_plant_types:
		result.append(plant_data.get_duplicate())

	# Pick the rest of the plants
	for i in number_of_plants - result.size():
		var pick:PlantData = _all_available_plants.pick_random()
		result.append(pick.get_duplicate())

	return result

func _contract_has_same_plant_types(contract:ContractData, plant_types:Array[PlantData]) -> bool:
	var unique_plants_in_contract := []
	for plant:PlantData in contract.plants:
		if !unique_plants_in_contract.has(plant):
			unique_plants_in_contract.append(plant)
	if unique_plants_in_contract.size() != plant_types.size():
		return false
	for plant:PlantData in plant_types:
		if !unique_plants_in_contract.has(plant):
			return false
	return true
