class_name ContractGenerator
extends RefCounted

const TOTAL_COMMON_CONTRACTS_TO_GENERATE_PER_CHAPTER := 8
const TOTAL_ELITE_CONTRACTS_TO_GENERATE_PER_CHAPTER := 4
const TOTAL_BOSS_CONTRACTS_TO_GENERATE_PER_CHAPTER := 3

const BASE_PLANT_DIFFICULTY_FOR_TYPE := {
	ContractData.ContractType.COMMON: 1,
	ContractData.ContractType.ELITE: 2,
	ContractData.ContractType.BOSS: 3,
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
var _boss_contracts:Array[ContractData] = []

func generate_contracts(chapter:int) -> void:
	_common_contracts = _generate_contracts(chapter, ContractData.ContractType.COMMON, TOTAL_COMMON_CONTRACTS_TO_GENERATE_PER_CHAPTER)
	_elite_contracts = _generate_contracts(chapter, ContractData.ContractType.ELITE, TOTAL_ELITE_CONTRACTS_TO_GENERATE_PER_CHAPTER)
	_boss_contracts = _generate_contracts(chapter, ContractData.ContractType.BOSS, TOTAL_BOSS_CONTRACTS_TO_GENERATE_PER_CHAPTER)

func _generate_contracts(chapter:int, type:ContractData.ContractType, count:int) -> Array[ContractData]:
	var contracts:Array[ContractData] = []
	for i in count:
		var contract:ContractData = ContractData.new()
		contract.contract_type = type
		contract.grace_period = BASE_GRACE_PERIOD + chapter
		contract.penalty_rate = BASE_PENALTY_RATE_FOR_TYPE[type] + chapter

		# Plants
		var plant_difficulty = BASE_PLANT_DIFFICULTY_FOR_TYPE[type] + chapter

		# Gold and rating rewards
		var reward_value = BASE_REWARD_VALUE_FOR_TYPE[type] + chapter * REWARD_VALUE_CHAPTER_MULTIPLIER
		var has_rating_reward = randf() < RATING_REWARD_CHANCE
		if has_rating_reward:
			contract.reward_rating = ceili((reward_value/2) * RATING_REWARD_RATE)
			contract.reward_gold = floori(reward_value/2)
		else:
			contract.reward_gold = reward_value

		# Booster pack rewards
		contract.reward_booster_pack_type = BASE_BOOSTER_PACK_TYPE_FOR_TYPE[type]

		contracts.append(contract)
	return contracts
