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
	EPIC,
}

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
