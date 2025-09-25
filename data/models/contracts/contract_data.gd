class_name ContractData
extends ThingData

enum ContractType {
	COMMON,
	ELITE,
	BOSS,
}

enum BoosterPackType {
	NONE,
	COMMON,
	RARE,
	LEGENDARY,
}

const BOOSTER_PACK_CARD_CHANCES := {
	BoosterPackType.COMMON: [70, 29, 1],
	BoosterPackType.RARE: [20, 70, 10],
	BoosterPackType.LEGENDARY: [0, 0, 100],
}

const BOOSTER_PACK_CARD_BASE_COUNTS := {
	BoosterPackType.COMMON: [0, 0 , 0],
	BoosterPackType.RARE: [ 0, 1, 0],
	BoosterPackType.LEGENDARY: [0, 0, 0],
}

const NUMBER_OF_CARDS_IN_BOOSTER_PACK := 3

@export var contract_type:ContractType
@export var plants:Array[PlantData]
@export var grace_period:int
@export var penalty_rate:int
@export var reward_gold:int
@export var reward_rating:int
@export var reward_booster_pack_type:BoosterPackType

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_contract: ContractData = other as ContractData
	contract_type = other_contract.contract_type
	plants = other_contract.plants.duplicate()
	grace_period = other_contract.grace_period
	penalty_rate = other_contract.penalty_rate
	reward_gold = other_contract.reward_gold
	reward_rating = other_contract.reward_rating
	reward_booster_pack_type = other_contract.reward_booster_pack_type

func get_duplicate() -> ContractData:
	var dup:ContractData = ContractData.new()
	dup.copy(self)
	return dup

func apply_contract_actions(_main_game:MainGame) -> void:
	await Util.await_for_tiny_time()

func log() -> void:
	print("contract =================================================")
	print("contract_type: ", ContractType.keys()[contract_type])
	for plant in plants:
		print("plant: ", plant.id)
	print("grace_period: ", grace_period)
	print("penalty_rate: ", penalty_rate)
	print("reward_gold: ", reward_gold)
	print("reward_rating: ", reward_rating)
	print("reward_booster_pack_type: ", BoosterPackType.keys()[reward_booster_pack_type])
	print("==========================================================")

static func get_booster_pack_name(booster_pack_type:BoosterPackType) -> String:
	match booster_pack_type:
		BoosterPackType.COMMON:
			return Util.get_localized_string("BOOSTER_PACK_NAME_COMMON")
		BoosterPackType.RARE:
			return Util.get_localized_string("BOOSTER_PACK_NAME_RARE")
		BoosterPackType.LEGENDARY:
			return Util.get_localized_string("BOOSTER_PACK_NAME_LEGENDARY")
	return ""
