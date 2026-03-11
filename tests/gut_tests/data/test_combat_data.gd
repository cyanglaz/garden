extends GutTest

# Tests for CombatData – combat encounter configuration.

const FAKE_PATH := "res://fake/test_combat.tres"

func _make_boss_data() -> BossData:
	var bd := BossData.new()
	bd.set("_original_resource_path", FAKE_PATH)
	bd.id = "boss_1"
	bd.primary_plant_id = "rose"
	return bd

func _make_combat(type: CombatData.CombatType = CombatData.CombatType.COMMON) -> CombatData:
	var cd := CombatData.new()
	cd.set("_original_resource_path", FAKE_PATH)
	cd.id = "combat_1"
	cd.combat_type = type
	cd.plants = []
	cd.boss_data = _make_boss_data()
	return cd

# ----- reward_gold -----

func test_reward_gold_common():
	var cd := _make_combat(CombatData.CombatType.COMMON)
	assert_eq(cd.reward_gold, 12)

func test_reward_gold_elite():
	var cd := _make_combat(CombatData.CombatType.ELITE)
	assert_eq(cd.reward_gold, 18)

func test_reward_gold_boss():
	var cd := _make_combat(CombatData.CombatType.BOSS)
	assert_eq(cd.reward_gold, 28)

# ----- reward_hp -----

func test_reward_hp_common_is_zero():
	var cd := _make_combat(CombatData.CombatType.COMMON)
	assert_eq(cd.reward_hp, 0)

func test_reward_hp_elite():
	var cd := _make_combat(CombatData.CombatType.ELITE)
	assert_eq(cd.reward_hp, 1)

func test_reward_hp_boss():
	var cd := _make_combat(CombatData.CombatType.BOSS)
	assert_eq(cd.reward_hp, 5)

# ----- reward_booster_pack_type -----

func test_booster_pack_type_for_common_combat():
	var cd := _make_combat(CombatData.CombatType.COMMON)
	assert_eq(cd.reward_booster_pack_type, CombatData.BoosterPackType.COMMON)

func test_booster_pack_type_for_elite_combat():
	var cd := _make_combat(CombatData.CombatType.ELITE)
	assert_eq(cd.reward_booster_pack_type, CombatData.BoosterPackType.RARE)

func test_booster_pack_type_for_boss_combat():
	var cd := _make_combat(CombatData.CombatType.BOSS)
	assert_eq(cd.reward_booster_pack_type, CombatData.BoosterPackType.LEGENDARY)

# ----- constants -----

func test_reward_gold_constant_values():
	assert_eq(CombatData.REWARD_GOLD[CombatData.CombatType.COMMON], 12)
	assert_eq(CombatData.REWARD_GOLD[CombatData.CombatType.ELITE], 18)
	assert_eq(CombatData.REWARD_GOLD[CombatData.CombatType.BOSS], 28)

func test_reward_hp_constant_values():
	assert_eq(CombatData.REWARD_HP[CombatData.CombatType.COMMON], 0)
	assert_eq(CombatData.REWARD_HP[CombatData.CombatType.ELITE], 1)
	assert_eq(CombatData.REWARD_HP[CombatData.CombatType.BOSS], 5)

func test_number_of_cards_in_booster_pack():
	assert_eq(CombatData.NUMBER_OF_CARDS_IN_BOOSTER_PACK, 3)

func test_booster_pack_card_chances_common_sums_to_100():
	var chances: Array = CombatData.BOOSTER_PACK_CARD_CHANCES[CombatData.BoosterPackType.COMMON]
	var total := 0
	for c in chances:
		total += c
	assert_eq(total, 100)

func test_booster_pack_card_chances_rare_sums_to_100():
	var chances: Array = CombatData.BOOSTER_PACK_CARD_CHANCES[CombatData.BoosterPackType.RARE]
	var total := 0
	for c in chances:
		total += c
	assert_eq(total, 100)

func test_booster_pack_card_chances_legendary_sums_to_100():
	var chances: Array = CombatData.BOOSTER_PACK_CARD_CHANCES[CombatData.BoosterPackType.LEGENDARY]
	var total := 0
	for c in chances:
		total += c
	assert_eq(total, 100)

func test_booster_pack_chances_have_three_tiers():
	for pack_type in CombatData.BoosterPackType.values():
		var chances: Array = CombatData.BOOSTER_PACK_CARD_CHANCES[pack_type]
		assert_eq(chances.size(), 3)

# ----- copy / get_duplicate -----

func test_duplicate_copies_combat_type():
	var cd := _make_combat(CombatData.CombatType.ELITE)
	var dup := cd.get_duplicate()
	assert_eq(dup.combat_type, CombatData.CombatType.ELITE)

func test_duplicate_copies_id():
	var cd := _make_combat()
	cd.id = "combat_42"
	var dup := cd.get_duplicate()
	assert_eq(dup.id, "combat_42")

func test_duplicate_plants_array_is_independent():
	var cd := _make_combat()
	cd.plants = []
	var dup := cd.get_duplicate()
	dup.plants.append(PlantData.new())
	assert_eq(cd.plants.size(), 0)

# ----- BossData -----

func test_boss_data_duplicate_copies_id():
	var bd := _make_boss_data()
	bd.id = "final_boss"
	var dup := bd.get_duplicate()
	assert_eq(dup.id, "final_boss")

func test_boss_data_duplicate_copies_primary_plant_id():
	var bd := _make_boss_data()
	bd.primary_plant_id = "venus_flytrap"
	var dup := bd.get_duplicate()
	assert_eq(dup.primary_plant_id, "venus_flytrap")

func test_boss_data_primary_plant_id_independent():
	var bd := _make_boss_data()
	bd.primary_plant_id = "rose"
	var dup := bd.get_duplicate()
	dup.primary_plant_id = "lily"
	assert_eq(bd.primary_plant_id, "rose")
