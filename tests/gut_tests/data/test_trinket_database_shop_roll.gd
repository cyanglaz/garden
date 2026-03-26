extends GutTest

# Tests for TrinketDatabase._select_shop_trinkets()
# The static helper contains all the composition logic and is tested here
# without requiring the full database to load from disk.

var _id_counter := 0

func _make_trinket(rarity_val: int) -> TrinketData:
	var td := TrinketData.new()
	td.id = "test_trinket_%d" % _id_counter
	_id_counter += 1
	td.rarity = rarity_val
	return td

func _make_pool(common_count: int, uncommon_count: int) -> Array:
	var pool: Array = []
	for _i in common_count:
		pool.append(_make_trinket(0))
	for _i in uncommon_count:
		pool.append(_make_trinket(1))
	return pool

# ----- ideal case -----

func test_ideal_case_returns_3_trinkets():
	var pool := _make_pool(3, 2)
	var result := TrinketDatabase._select_shop_trinkets(pool)
	assert_eq(result.size(), 3)

func test_ideal_case_returns_2_common_1_uncommon():
	var pool := _make_pool(3, 2)
	var result := TrinketDatabase._select_shop_trinkets(pool)
	var common_count := result.filter(func(t: TrinketData) -> bool: return t.rarity == 0).size()
	var uncommon_count := result.filter(func(t: TrinketData) -> bool: return t.rarity == 1).size()
	assert_eq(common_count, 2)
	assert_eq(uncommon_count, 1)

func test_ideal_case_no_duplicate_ids():
	var pool := _make_pool(3, 2)
	var result := TrinketDatabase._select_shop_trinkets(pool)
	var ids: Array = result.map(func(t: TrinketData) -> String: return t.id)
	# all ids are unique
	var unique_ids := {}
	for id in ids:
		unique_ids[id] = true
	assert_eq(unique_ids.size(), result.size())

func test_exact_2_common_1_uncommon_available_returns_all_3():
	var pool := _make_pool(2, 1)
	var result := TrinketDatabase._select_shop_trinkets(pool)
	assert_eq(result.size(), 3)
	var common_count := result.filter(func(t: TrinketData) -> bool: return t.rarity == 0).size()
	var uncommon_count := result.filter(func(t: TrinketData) -> bool: return t.rarity == 1).size()
	assert_eq(common_count, 2)
	assert_eq(uncommon_count, 1)

# ----- fallback: no uncommon -----

func test_no_uncommon_returns_up_to_3():
	var pool := _make_pool(5, 0)
	var result := TrinketDatabase._select_shop_trinkets(pool)
	assert_eq(result.size(), 3)

func test_no_uncommon_all_results_are_common():
	var pool := _make_pool(5, 0)
	var result := TrinketDatabase._select_shop_trinkets(pool)
	for t: TrinketData in result:
		assert_eq(t.rarity, 0)

func test_no_uncommon_fallback_no_duplicate_ids():
	var pool := _make_pool(5, 0)
	var result := TrinketDatabase._select_shop_trinkets(pool)
	var unique_ids := {}
	for t: TrinketData in result:
		unique_ids[t.id] = true
	assert_eq(unique_ids.size(), result.size())

# ----- fallback: fewer than 2 common -----

func test_1_common_2_uncommon_triggers_fallback():
	var pool := _make_pool(1, 2)
	var result := TrinketDatabase._select_shop_trinkets(pool)
	assert_eq(result.size(), 3)

func test_0_common_3_uncommon_triggers_fallback():
	var pool := _make_pool(0, 3)
	var result := TrinketDatabase._select_shop_trinkets(pool)
	assert_eq(result.size(), 3)
	for t: TrinketData in result:
		assert_eq(t.rarity, 1)

# ----- partial fill -----

func test_empty_pool_returns_empty():
	var pool: Array = []
	var result := TrinketDatabase._select_shop_trinkets(pool)
	assert_eq(result.size(), 0)

func test_1_trinket_available_returns_1():
	var pool := _make_pool(1, 0)
	var result := TrinketDatabase._select_shop_trinkets(pool)
	assert_eq(result.size(), 1)

func test_2_trinkets_in_fallback_returns_2():
	# 1 common + 1 uncommon is not enough for ideal (needs 2 common)
	var pool := _make_pool(1, 1)
	var result := TrinketDatabase._select_shop_trinkets(pool)
	assert_eq(result.size(), 2)

# ----- result is duplicates, not originals -----

func test_result_contains_duplicates_not_originals():
	var pool := _make_pool(2, 1)
	var result := TrinketDatabase._select_shop_trinkets(pool)
	# None of the result objects should be the same instance as pool members
	for res_trinket: TrinketData in result:
		for pool_trinket: TrinketData in pool:
			assert_ne(res_trinket, pool_trinket)
