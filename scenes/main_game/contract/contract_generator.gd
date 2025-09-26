class_name ContractGenerator
extends RefCounted

const MAX_REROLL_PLANTS_COUNT := 100
const TOTAL_COMMON_CONTRACTS_TO_GENERATE_PER_CHAPTER := 6
const TOTAL_ELITE_CONTRACTS_TO_GENERATE_PER_CHAPTER := 4
const TOTAL_BOSS_CONTRACTS_TO_GENERATE_PER_CHAPTER := 1
const ELITE_CONTRACT_CHANCE := 0.5
const REWARD_VALUE_CHAPTER_MULTIPLIER := 3
const RATING_REWARD_CHANCE := 0.1
const RATING_REWARD_RATE := 0.5

const BASE_NUMBER_OF_PLANTS_DICE := {
	3: 5,
	4: 60,
	5: 30,
	6: 50000,
}

const NUMBER_OF_PLANTS_TYPE_DICE := {
	1: 15,
	2: 70,
	3: 15
}


const TOP_PLANT_DIFFICULTY_FOR_TYPE := {
	ContractData.ContractType.COMMON: 0,
	ContractData.ContractType.ELITE: 1,
	ContractData.ContractType.BOSS: 2,
}

const BASE_REWARD_VALUE_FOR_EACH_PLANT_DIFFICULTY_TYPE := {
	0: 2,
	1: 4,
	2: 6,
}

const BASE_BOOSTER_PACK_TYPE_FOR_TYPE := {
	ContractData.ContractType.COMMON: ContractData.BoosterPackType.COMMON,
	ContractData.ContractType.ELITE: ContractData.BoosterPackType.RARE,
	ContractData.ContractType.BOSS: ContractData.BoosterPackType.LEGENDARY,
}

const BASE_GRACE_PERIOD := 4
const BASE_PENALTY_RATE_FOR_TYPE := {
	ContractData.ContractType.COMMON: 1,
	ContractData.ContractType.ELITE: 2,
	ContractData.ContractType.BOSS: 2,
}

var common_contracts:Array[ContractData] = []
var elite_contracts:Array[ContractData] = []
var boss_contracts:Array[ContractData] = []

var _all_available_plants:Array = []

func generate_contracts(chapter:int) -> void:
	_all_available_plants = MainDatabase.plant_database.get_plants_by_chapter(chapter)
	common_contracts = _generate_contracts(chapter, ContractData.ContractType.COMMON, TOTAL_COMMON_CONTRACTS_TO_GENERATE_PER_CHAPTER)
	elite_contracts = _generate_contracts(chapter, ContractData.ContractType.ELITE, TOTAL_ELITE_CONTRACTS_TO_GENERATE_PER_CHAPTER)
	boss_contracts = _generate_contracts(chapter, ContractData.ContractType.BOSS, 1)
	_log_contracts(chapter)

func pick_contracts(number_of_contracts:int, level:int) -> Array:
	var number_of_common_contracts := 0
	var number_of_elite_contracts := 0
	var number_of_boss_contracts := 0
	if level == 0:
		# First level are always common contracts
		number_of_common_contracts = number_of_contracts
	elif level == 1:
		# Second level has a chance to have 1 elite contract
		var rand := randf()
		if rand < ELITE_CONTRACT_CHANCE:
			number_of_elite_contracts = 1
		number_of_common_contracts = number_of_contracts - number_of_elite_contracts
	elif level == 2:
		# Third level, roll twice for elite contract
		var rand := randf()
		if rand < ELITE_CONTRACT_CHANCE:
			number_of_elite_contracts = 1
		rand = randf()
		if rand < ELITE_CONTRACT_CHANCE:
			number_of_elite_contracts += 1
		number_of_common_contracts = number_of_contracts - number_of_elite_contracts
	elif level == 3:
		# Fourth level is boss level
		number_of_boss_contracts = 1
	var picks := []
	if number_of_common_contracts > 0:
		var common_picks := Util.unweighted_roll(common_contracts, number_of_common_contracts)
		for pick in common_picks:
			common_contracts.erase(pick)
		picks += common_picks
	if number_of_elite_contracts > 0:
		var elite_picks := Util.unweighted_roll(elite_contracts, number_of_elite_contracts)
		for pick in elite_picks:
			elite_contracts.erase(pick)
		picks += elite_picks
	if number_of_boss_contracts > 0:
		var boss_picks := Util.unweighted_roll(boss_contracts, number_of_boss_contracts)
		for pick in boss_picks:
			boss_contracts.erase(pick)
		picks += boss_picks
	return picks

func _generate_contracts(chapter:int, contract_type:ContractData.ContractType, count:int) -> Array[ContractData]:
	var contracts:Array[ContractData] = []
	for i in count:
		var contract:ContractData = ContractData.new()
		contract.contract_type = contract_type
		contract.grace_period = BASE_GRACE_PERIOD + chapter
		contract.penalty_rate = BASE_PENALTY_RATE_FOR_TYPE[contract_type] + chapter

		# Plants
		contract.plants = _roll_plants(chapter, contract_type, contracts)

		# Gold and rating rewards
		_roll_reward_values(contract, chapter)

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

func _roll_plants(chapter:int, contract_type:ContractData.ContractType, contracts:Array[ContractData]) -> Array[PlantData]:
	var top_plant_difficulty:int = TOP_PLANT_DIFFICULTY_FOR_TYPE[contract_type] + chapter
	var pick_result:Array[PlantData] = []
	for i in MAX_REROLL_PLANTS_COUNT:
		var roll_once_result := _roll_plants_once(chapter, top_plant_difficulty)
		# Ensure the plant combinations are unique
		pick_result = roll_once_result
		for contract:ContractData in contracts:
			if !_contract_has_same_plant_types(contract, roll_once_result):
				break
	return pick_result

func _roll_plants_once(chapter:int, top_plant_difficulty:int) -> Array[PlantData]:
	var number_of_plants := _roll_number_of_plants(chapter)
	var number_of_plants_type := _roll_number_of_plants_type(chapter)

	# Find the plants match the top plant difficulty
	var primary_plants:Array = _all_available_plants.filter(
		func(plant:PlantData) -> bool: return plant.difficulty == top_plant_difficulty
	)
	# Find the plants match the second top plant difficulty
	var secondary_plants:Array = _all_available_plants.filter(
		func(plant:PlantData) -> bool: return plant.difficulty == top_plant_difficulty - 1
	)

	var selected_plant_types:Array[PlantData] = []

	# Pick the primary plant
	var primary_pick:PlantData = primary_plants.pick_random()
	selected_plant_types.append(primary_pick)
	primary_plants.erase(primary_pick)
	var rest_available_plants:Array = primary_plants + secondary_plants
	assert(rest_available_plants.size() > number_of_plants_type - 1)
	for i in number_of_plants_type - 1:
		var pick:PlantData = rest_available_plants.pick_random()
		selected_plant_types.append(pick)
		rest_available_plants.erase(pick)

	var result:Array[PlantData] = []
	# Pick each selection at least once
	for plant_data:PlantData in selected_plant_types:
		result.append(plant_data.get_duplicate())

	# Pick the rest of the plants
	for i in number_of_plants - result.size():
		var pick:PlantData = selected_plant_types.pick_random()
		result.append(pick.get_duplicate())
	result.shuffle()

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

func _roll_reward_values(contract:ContractData, chapter:int) -> void:
	var reward_value := 0
	for plant:PlantData in contract.plants:
		reward_value += BASE_REWARD_VALUE_FOR_EACH_PLANT_DIFFICULTY_TYPE[plant.difficulty]
	reward_value += chapter * REWARD_VALUE_CHAPTER_MULTIPLIER
	var has_rating_reward = randf() < RATING_REWARD_CHANCE
	if has_rating_reward:
		@warning_ignore("integer_division")
		contract.reward_rating = ceili((reward_value/2) * RATING_REWARD_RATE)
		@warning_ignore("integer_division")
		contract.reward_gold = floori(reward_value/2)
	else:
		contract.reward_gold = reward_value

func _log_contracts(chapter:int) -> void:
	print("chapter: ", chapter)
	print("common_contracts:")
	for contract in common_contracts:
		contract.log()
	print("elite_contracts:")
	for contract in elite_contracts:
		contract.log()
	print("boss_contract:")
	for contract in boss_contracts:
		contract.log()
