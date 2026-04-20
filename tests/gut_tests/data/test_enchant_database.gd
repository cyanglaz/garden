extends GutTest

# Tests for EnchantDatabase.roll_purchasable_enchants() and the resource files on disk.
# roll_purchasable_enchants(count) is exercised by seeding _datas directly to avoid disk IO
# coupling, mirroring the approach in test_trinket_database_shop_roll.gd.

const FAKE_PATH := "res://fake/test_enchant.tres"

func _make_action(action_type: ActionData.ActionType = ActionData.ActionType.WATER) -> ActionData:
	var ad := ActionData.new()
	ad.set("_original_resource_path", FAKE_PATH)
	ad.type = action_type
	ad.value = 1
	ad.value_type = ActionData.ValueType.NUMBER
	return ad

func _make_enchant(id_val: String, rarity_val: int = 0) -> EnchantData:
	var ed := EnchantData.new()
	ed.set("_original_resource_path", "res://fake/%s.tres" % id_val)
	ed.id = id_val
	ed.rarity = rarity_val
	ed.action_data = _make_action()
	return ed

func _make_db(enchants: Array) -> EnchantDatabase:
	var db := EnchantDatabase.new()
	add_child(db)
	autofree(db)
	db._datas.clear()
	for e: EnchantData in enchants:
		db._datas[e.id] = e
	return db

# ----- roll_purchasable_enchants count bounds -----

func test_roll_zero_returns_empty():
	var db := _make_db([_make_enchant("a"), _make_enchant("b")])
	var result := db.roll_purchasable_enchants(0)
	assert_eq(result.size(), 0)

func test_roll_one_returns_one():
	var db := _make_db([_make_enchant("a"), _make_enchant("b")])
	var result := db.roll_purchasable_enchants(1)
	assert_eq(result.size(), 1)

func test_roll_n_returns_n_when_pool_large_enough():
	var db := _make_db([
		_make_enchant("a"),
		_make_enchant("b"),
		_make_enchant("c"),
		_make_enchant("d"),
	])
	var result := db.roll_purchasable_enchants(3)
	assert_eq(result.size(), 3)

func test_roll_caps_at_pool_size_when_count_exceeds_available():
	var db := _make_db([_make_enchant("a"), _make_enchant("b")])
	var result := db.roll_purchasable_enchants(5)
	assert_eq(result.size(), 2)

# ----- uniqueness + pool membership -----

func test_roll_returns_unique_ids():
	var db := _make_db([
		_make_enchant("a"),
		_make_enchant("b"),
		_make_enchant("c"),
	])
	var result := db.roll_purchasable_enchants(3)
	var unique_ids := {}
	for e: EnchantData in result:
		unique_ids[e.id] = true
	assert_eq(unique_ids.size(), result.size())

func test_roll_only_returns_enchants_from_pool():
	var ids := ["a", "b", "c", "d"]
	var pool: Array = []
	for id in ids:
		pool.append(_make_enchant(id))
	var db := _make_db(pool)
	var result := db.roll_purchasable_enchants(3)
	for e: EnchantData in result:
		assert_true(e.id in ids)

# ----- results are duplicates, not originals -----

func test_roll_returns_duplicates_not_originals():
	var originals: Array = [_make_enchant("a"), _make_enchant("b")]
	var db := _make_db(originals)
	var result := db.roll_purchasable_enchants(2)
	for res_enchant: EnchantData in result:
		for original: EnchantData in originals:
			assert_ne(res_enchant, original)

# ----- rarity weighting robustness -----

func test_roll_with_unknown_rarity_does_not_crash():
	# Rarities not in RARITY_WEIGHTS fall back to weight 1 via .get(e.rarity, 1).
	var db := _make_db([
		_make_enchant("a", 5),
		_make_enchant("b", 99),
	])
	var result := db.roll_purchasable_enchants(2)
	assert_eq(result.size(), 2)

# ----- smoke: validate all 8 .tres resources load via the autoload -----

func test_all_enchant_resources_load_via_main_database():
	var all_enchants: Array = MainDatabase.enchant_database.get_all_datas()
	for e: EnchantData in all_enchants:
		assert_not_null(e)
		assert_true(e is EnchantData)
		assert_false(e.id.is_empty())
		assert_not_null(e.action_data)

# ----- EnchantData.cost by rarity -----

func test_enchant_cost_rarity_0_is_15():
	var e := _make_enchant("a", 0)
	assert_eq(e.cost, 15)

func test_enchant_cost_rarity_1_is_30():
	var e := _make_enchant("a", 1)
	assert_eq(e.cost, 30)

# ----- roll_shop_enchants: 2 common + 1 uncommon -----

func test_roll_shop_returns_three_when_pools_sufficient():
	var db := _make_db([
		_make_enchant("c1", 0),
		_make_enchant("c2", 0),
		_make_enchant("c3", 0),
		_make_enchant("u1", 1),
		_make_enchant("u2", 1),
	])
	var result: Array[EnchantData] = db.roll_shop_enchants()
	assert_eq(result.size(), 3)

func test_roll_shop_returns_two_commons_and_one_uncommon():
	var db := _make_db([
		_make_enchant("c1", 0),
		_make_enchant("c2", 0),
		_make_enchant("c3", 0),
		_make_enchant("u1", 1),
		_make_enchant("u2", 1),
	])
	var result: Array[EnchantData] = db.roll_shop_enchants()
	var common_count := 0
	var uncommon_count := 0
	for e: EnchantData in result:
		if e.rarity == 0:
			common_count += 1
		elif e.rarity == 1:
			uncommon_count += 1
	assert_eq(common_count, 2)
	assert_eq(uncommon_count, 1)

func test_roll_shop_returns_unique_ids():
	var db := _make_db([
		_make_enchant("c1", 0),
		_make_enchant("c2", 0),
		_make_enchant("c3", 0),
		_make_enchant("u1", 1),
		_make_enchant("u2", 1),
	])
	var result: Array[EnchantData] = db.roll_shop_enchants()
	var unique_ids := {}
	for e: EnchantData in result:
		unique_ids[e.id] = true
	assert_eq(unique_ids.size(), result.size())

func test_roll_shop_returns_duplicates_not_originals():
	var originals: Array = [
		_make_enchant("c1", 0),
		_make_enchant("c2", 0),
		_make_enchant("u1", 1),
	]
	var db := _make_db(originals)
	var result: Array[EnchantData] = db.roll_shop_enchants()
	for res_enchant: EnchantData in result:
		for original: EnchantData in originals:
			assert_ne(res_enchant, original)

func test_roll_shop_filters_out_rarity_two_or_higher():
	var db := _make_db([
		_make_enchant("c1", 0),
		_make_enchant("c2", 0),
		_make_enchant("u1", 1),
		_make_enchant("r1", 2),
		_make_enchant("r2", 3),
	])
	var result: Array[EnchantData] = db.roll_shop_enchants()
	for e: EnchantData in result:
		assert_true(e.rarity < 2, "rarity %d should have been filtered out" % e.rarity)

func test_roll_shop_fallback_when_no_uncommon():
	# If there is no uncommon pool member, fall back to picking up to 3 unique
	# enchants from the combined rarity<2 pool.
	var db := _make_db([
		_make_enchant("c1", 0),
		_make_enchant("c2", 0),
		_make_enchant("c3", 0),
	])
	var result: Array[EnchantData] = db.roll_shop_enchants()
	assert_eq(result.size(), 3)
	var unique_ids := {}
	for e: EnchantData in result:
		unique_ids[e.id] = true
	assert_eq(unique_ids.size(), 3)

func test_roll_shop_fallback_when_fewer_than_two_commons():
	var db := _make_db([
		_make_enchant("c1", 0),
		_make_enchant("u1", 1),
		_make_enchant("u2", 1),
	])
	var result: Array[EnchantData] = db.roll_shop_enchants()
	assert_eq(result.size(), 3)
	var unique_ids := {}
	for e: EnchantData in result:
		unique_ids[e.id] = true
	assert_eq(unique_ids.size(), 3)
