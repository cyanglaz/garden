class_name CombatData
extends ThingData

enum CombatType {
	COMMON,
	ELITE,
	BOSS,
}

enum BoosterPackType {
	COMMON,
	RARE,
	LEGENDARY,
}

const BOOSTER_PACK_CARD_CHANCES := {
	BoosterPackType.COMMON: [50, 40, 10],
	BoosterPackType.RARE: [30, 60, 10],
	BoosterPackType.LEGENDARY: [0, 0, 100],
}

const BOOSTER_PACK_CARD_BASE_COUNTS := {
	BoosterPackType.COMMON: [2, 0 , 0],
	BoosterPackType.RARE: [ 0, 2, 0],
	BoosterPackType.LEGENDARY: [0, 0, 0],
}

const REWARD_GOLD := {
	CombatType.COMMON: 12,
	CombatType.ELITE: 18,
	CombatType.BOSS: 28,
}

const REWARD_HP := {
	CombatType.COMMON: 0,
	CombatType.ELITE: 5,
	CombatType.BOSS: 50,
}

const NUMBER_OF_CARDS_IN_BOOSTER_PACK := 3
const PENALTY_INCREASE_DAYS := 3

@export var combat_type:CombatType
@export var plants:Array[PlantData]
@export var boss_data:BossData

var reward_gold:int: get = _get_reward_gold
var reward_hp:int: get = _get_reward_hp
var reward_booster_pack_type:BoosterPackType: get = _get_reward_booster_pack_type
var penalty_rate:int: get = _get_penalty_rate

func copy(other:ThingData) -> void:
	super.copy(other)
	var other_combat: CombatData = other as CombatData
	combat_type = other_combat.combat_type
	plants = other_combat.plants.duplicate()
	penalty_rate = other_combat.penalty_rate
	boss_data = other_combat.boss_data.get_duplicate()

func get_duplicate() -> CombatData:
	var dup:CombatData = CombatData.new()
	dup.copy(self)
	return dup
	
func get_penalty_rate(day:int) -> int:
	@warning_ignore("integer_division")
	return penalty_rate + day/PENALTY_INCREASE_DAYS

func log() -> void:
	print("combat =================================================")
	print("combat_type: ", CombatType.keys()[combat_type])
	for plant in plants:
		print("plant: ", plant.id)
	print("penalty_rate: ", penalty_rate)
	print("reward_gold: ", reward_gold)
	print("reward_hp: ", reward_hp)
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

func _get_reward_gold() -> int:
	return REWARD_GOLD[combat_type]

func _get_reward_hp() -> int:
	return REWARD_HP[combat_type]

func _get_reward_booster_pack_type() -> BoosterPackType:
	match combat_type:
		CombatType.COMMON:
			return BoosterPackType.COMMON
		CombatType.ELITE:
			return BoosterPackType.RARE
		CombatType.BOSS:
			return BoosterPackType.LEGENDARY
		_:
			assert(false, "Invalid combat type: %s" % combat_type)
	return BoosterPackType.COMMON

func _get_penalty_rate() -> int:
	match combat_type:
		CombatType.COMMON:
			return 1
		CombatType.ELITE:
			return 2
		CombatType.BOSS:
			return 3
		_:
			assert(false, "Invalid combat type: %s" % combat_type)
	return 1
