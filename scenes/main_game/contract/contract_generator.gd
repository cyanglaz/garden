class_name CombatGenerator
extends RefCounted

const MAX_REROLL_PLANTS_COUNT := 100
const TOTAL_COMMON_COMBATS_TO_GENERATE_PER_CHAPTER := 6
const TOTAL_ELITE_COMBATS_TO_GENERATE_PER_CHAPTER := 4
const TOTAL_BOSS_COMBATS_TO_GENERATE_PER_CHAPTER := 1
const ELITE_COMBAT_CHANCE := 0.5
const REWARD_VALUE_CHAPTER_MULTIPLIER := 3

const BOSS_LEVEL := 3

const BASE_NUMBER_OF_PLANTS_DICE := {
	4: 55,
	5: 45,
}

const NUMBER_OF_PLANTS_TYPE_DICE := {
	2: 75,
	3: 25
}

const TOP_PLANT_DIFFICULTY_FOR_TYPE := {
	CombatData.CombatType.COMMON: 0,
	CombatData.CombatType.ELITE: 1,
	CombatData.CombatType.BOSS: 2,
}

const BASE_REWARD_VALUE_FOR_EACH_PLANT_DIFFICULTY_TYPE := {
	0: 2,
	1: 4,
	2: 6,
}

const BOSS_HP_REWARD := 50

const BASE_BOOSTER_PACK_TYPE_FOR_TYPE := {
	CombatData.CombatType.COMMON: CombatData.BoosterPackType.COMMON,
	CombatData.CombatType.ELITE: CombatData.BoosterPackType.RARE,
	CombatData.CombatType.BOSS: CombatData.BoosterPackType.LEGENDARY,
}

const BASE_PENALTY_RATE_FOR_TYPE := {
	CombatData.CombatType.COMMON: 1,
	CombatData.CombatType.ELITE: 2,
	CombatData.CombatType.BOSS: 2,
}

var bosses:Array[BossData] = []

var common_combats:Array[CombatData] = []
var elite_combats:Array[CombatData] = []
var boss_combats:Array[CombatData] = []

var _all_available_plants:Array = []

func generate_combats(chapter:int, number_of_common_combats:int, number_of_elite_combats:int, number_of_boss_combats:int) -> void:
	_all_available_plants = MainDatabase.plant_database.get_plants_by_chapter(chapter)
	common_combats = _generate_combats(chapter, CombatData.CombatType.COMMON, number_of_common_combats)
	elite_combats = _generate_combats(chapter, CombatData.CombatType.ELITE, number_of_elite_combats)
	boss_combats = _generate_combats(chapter, CombatData.CombatType.BOSS, number_of_boss_combats)
	_log_combats(chapter)

func _generate_combats(chapter:int, combat_type:CombatData.CombatType, count:int) -> Array[CombatData]:
	var combats:Array[CombatData] = []
	for i in count:
		var combat:CombatData = CombatData.new()
		combat.combat_type = combat_type
		combat.penalty_rate = BASE_PENALTY_RATE_FOR_TYPE[combat_type] + chapter

		if combat_type == CombatData.CombatType.BOSS:
			assert(bosses.size() > 0)
			combat.boss_data = bosses.pop_back()
			combat.plants = _roll_boss_plants(chapter, combat.boss_data)
		else:
			combat.boss_data = null
			combat.plants = _roll_plants(chapter, combat_type, combats)

		# Gold
		_roll_reward_values(combat, chapter)

		# Booster pack rewards
		combat.reward_booster_pack_type = BASE_BOOSTER_PACK_TYPE_FOR_TYPE[combat_type]


		combats.append(combat)
	return combats

func _roll_number_of_plants(chapter:int) -> int:
	var values := BASE_NUMBER_OF_PLANTS_DICE.keys()
	var weights := BASE_NUMBER_OF_PLANTS_DICE.values()
	return Util.weighted_roll(values, weights) + chapter

func _roll_number_of_plants_type(chapter:int) -> int:
	var values := NUMBER_OF_PLANTS_TYPE_DICE.keys()
	var weights := NUMBER_OF_PLANTS_TYPE_DICE.values()
	return Util.weighted_roll(values, weights) + chapter

func _roll_plants(chapter:int, combat_type:CombatData.CombatType, combats:Array[CombatData]) -> Array[PlantData]:
	var top_plant_difficulty:int = TOP_PLANT_DIFFICULTY_FOR_TYPE[combat_type] + chapter
	var pick_result:Array[PlantData] = []
	for i in MAX_REROLL_PLANTS_COUNT:
		var roll_once_result := _roll_plants_once(chapter, top_plant_difficulty)
		# Ensure the plant combinations are unique
		pick_result = roll_once_result
		for combat:CombatData in combats:
			if !_combat_has_same_plant_types(combat, roll_once_result):
				break
	return pick_result

func _roll_boss_plants(chapter:int, boss_data:BossData) -> Array[PlantData]:

	var number_of_plants := _roll_number_of_plants(chapter)
	var number_of_plants_type := _roll_number_of_plants_type(chapter)

	var available_secondary_plants:Array = _all_available_plants.filter(
		func(plant:PlantData) -> bool: return plant.difficulty == TOP_PLANT_DIFFICULTY_FOR_TYPE[CombatData.CombatType.ELITE]
	)
	var selected_plant_types:Array = Util.unweighted_roll(available_secondary_plants, number_of_plants_type-1)

	var primary_pick:PlantData = MainDatabase.plant_database.get_data_by_id(boss_data.primary_plant_id, true)

	var result:Array[PlantData] = []
	# Pick primary plant at least half of the time (ceiling)
	@warning_ignore("integer_division")
	for i in number_of_plants/2:
		result.append(primary_pick.get_duplicate())

	# Pick the rest of the plants
	for i in number_of_plants - result.size():
		var pick:PlantData = selected_plant_types.pick_random()
		result.append(pick.get_duplicate())
	result.shuffle()

	return result
	
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

	# Pick primary plant at least half of the time (ceiling)
	@warning_ignore("integer_division")
	for i in number_of_plants/2:
		result.append(primary_pick.get_duplicate())

	# Pick the rest of the plants
	for i in number_of_plants - result.size():
		var pick:PlantData = selected_plant_types.pick_random()
		result.append(pick.get_duplicate())
	result.shuffle()

	return result

func _combat_has_same_plant_types(combat:CombatData, plant_types:Array[PlantData]) -> bool:
	var unique_plants_in_combat := []
	for plant:PlantData in combat.plants:
		if !unique_plants_in_combat.has(plant):
			unique_plants_in_combat.append(plant)
	if unique_plants_in_combat.size() != plant_types.size():
		return false
	for plant:PlantData in plant_types:
		if !unique_plants_in_combat.has(plant):
			return false
	return true

func _roll_reward_values(combat:CombatData, chapter:int) -> void:
	var reward_value := 0
	for plant:PlantData in combat.plants:
		reward_value += BASE_REWARD_VALUE_FOR_EACH_PLANT_DIFFICULTY_TYPE[plant.difficulty]
	reward_value += chapter * REWARD_VALUE_CHAPTER_MULTIPLIER
	combat.reward_gold = reward_value
	if combat.combat_type == CombatData.CombatType.BOSS:
		combat.reward_hp += BOSS_HP_REWARD

func _log_combats(chapter:int) -> void:
	print("chapter: ", chapter)
	print("common_combats:")
	for combat in common_combats:
		combat.log()
	print("elite_combats:")
	for combat in elite_combats:
		combat.log()
	print("boss_combat:")
	for combat in boss_combats:
		combat.log()
