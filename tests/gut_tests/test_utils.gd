extends GutTest

# Tests for Util static methods that have no scene-tree or engine dependencies.

# ----- quadratic_bezier -----

func test_quadratic_bezier_at_t0_returns_p0():
	var p0 := Vector2(0, 0)
	var p1 := Vector2(50, 100)
	var p2 := Vector2(100, 0)
	var result := Util.quadratic_bezier(p0, p1, p2, 0.0)
	assert_eq(result, p0)

func test_quadratic_bezier_at_t1_returns_p2():
	var p0 := Vector2(0, 0)
	var p1 := Vector2(50, 100)
	var p2 := Vector2(100, 0)
	var result := Util.quadratic_bezier(p0, p1, p2, 1.0)
	assert_eq(result, p2)

func test_quadratic_bezier_at_t05_is_midpoint():
	var p0 := Vector2(0, 0)
	var p1 := Vector2(0, 0)
	var p2 := Vector2(100, 0)
	# With p1 == p0, the curve degenerates to a line from p0 toward p2
	var result := Util.quadratic_bezier(p0, p1, p2, 0.5)
	assert_true(Util.float_equal(result.x, 25.0))
	assert_true(Util.float_equal(result.y, 0.0))

# ----- is_collision_layer_bit_set -----

func test_collision_bit_set_returns_true_when_set():
	assert_true(Util.is_collision_layer_bit_set(0b0111, 0b0100))

func test_collision_bit_set_returns_false_when_not_set():
	assert_false(Util.is_collision_layer_bit_set(0b0011, 0b0100))

func test_collision_bit_set_with_single_bit_layer():
	assert_true(Util.is_collision_layer_bit_set(1, 1))
	assert_false(Util.is_collision_layer_bit_set(2, 1))

func test_collision_bit_set_multiple_bits():
	assert_true(Util.is_collision_layer_bit_set(0xFF, 0x0F))
	assert_false(Util.is_collision_layer_bit_set(0xF0, 0x0F))

# ----- float_equal -----

func test_float_equal_same_values():
	assert_true(Util.float_equal(1.0, 1.0))

func test_float_equal_within_epsilon():
	assert_true(Util.float_equal(1.0, 1.0009))

func test_float_equal_outside_epsilon():
	assert_false(Util.float_equal(1.0, 1.002))

func test_float_equal_zero():
	assert_true(Util.float_equal(0.0, 0.0))

func test_float_equal_negative_values():
	assert_true(Util.float_equal(-5.0, -5.0))
	assert_false(Util.float_equal(-5.0, -4.0))

# ----- split_with_delimiters -----

func test_split_with_single_delimiter():
	var result := Util.split_with_delimiters("a,b,c", [","])
	assert_eq(result.size(), 3)
	assert_true(result.has("a"))
	assert_true(result.has("b"))
	assert_true(result.has("c"))

func test_split_with_no_delimiter_match():
	var result := Util.split_with_delimiters("abc", [","])
	assert_eq(result.size(), 1)
	assert_eq(result[0], "abc")

func test_split_with_multiple_delimiters():
	var result := Util.split_with_delimiters("a,b;c", [",", ";"])
	assert_eq(result.size(), 3)
	assert_true(result.has("a"))
	assert_true(result.has("b"))
	assert_true(result.has("c"))

func test_split_empty_string():
	var result := Util.split_with_delimiters("", [","])
	assert_eq(result.size(), 1)

# ----- get_mutual_items_in_arrays -----

func test_mutual_items_returns_common_elements():
	var result := Util.get_mutual_items_in_arrays([1, 2, 3], [2, 3, 4])
	assert_eq(result.size(), 2)
	assert_true(2 in result)
	assert_true(3 in result)

func test_mutual_items_no_overlap():
	var result := Util.get_mutual_items_in_arrays([1, 2], [3, 4])
	assert_eq(result.size(), 0)

func test_mutual_items_identical_arrays():
	var result := Util.get_mutual_items_in_arrays([1, 2, 3], [1, 2, 3])
	assert_eq(result.size(), 3)

func test_mutual_items_empty_arrays():
	var result := Util.get_mutual_items_in_arrays([], [])
	assert_eq(result.size(), 0)

# ----- remove_duplicates_from_array -----

func test_remove_duplicates_keeps_unique():
	var result := Util.remove_duplicates_from_array([1, 2, 3])
	assert_eq(result.size(), 3)

func test_remove_duplicates_removes_repeated():
	var result := Util.remove_duplicates_from_array([1, 1, 2, 2, 3])
	assert_eq(result.size(), 3)
	assert_true(1 in result)
	assert_true(2 in result)
	assert_true(3 in result)

func test_remove_duplicates_empty_array():
	var result := Util.remove_duplicates_from_array([])
	assert_eq(result.size(), 0)

func test_remove_duplicates_preserves_order():
	var result := Util.remove_duplicates_from_array([3, 1, 2, 1, 3])
	assert_eq(result[0], 3)
	assert_eq(result[1], 1)
	assert_eq(result[2], 2)

# ----- array_find -----

func test_array_find_returns_index_of_first_match():
	var arr := [10, 20, 30]
	var idx := Util.array_find(arr, func(x): return x == 20)
	assert_eq(idx, 1)

func test_array_find_returns_minus_one_when_not_found():
	var arr := [10, 20, 30]
	var idx := Util.array_find(arr, func(x): return x == 99)
	assert_eq(idx, -1)

func test_array_find_returns_first_occurrence():
	var arr := [5, 5, 5]
	var idx := Util.array_find(arr, func(x): return x == 5)
	assert_eq(idx, 0)

# ----- array_find_all -----

func test_array_find_all_returns_all_matching_indices():
	var arr := [1, 2, 1, 3, 1]
	var indices := Util.array_find_all(arr, func(x): return x == 1)
	assert_eq(indices.size(), 3)
	assert_eq(indices[0], 0)
	assert_eq(indices[1], 2)
	assert_eq(indices[2], 4)

func test_array_find_all_returns_empty_when_no_match():
	var arr := [1, 2, 3]
	var indices := Util.array_find_all(arr, func(x): return x == 99)
	assert_eq(indices.size(), 0)

# ----- get_quality_text -----

func test_get_quality_text_common():
	assert_eq(Util.get_quality_text(0), "Common")

func test_get_quality_text_uncommon():
	assert_eq(Util.get_quality_text(1), "Uncommon")

func test_get_quality_text_rare():
	assert_eq(Util.get_quality_text(2), "Rare")

func test_get_quality_text_epic():
	assert_eq(Util.get_quality_text(3), "Epic")

func test_get_quality_text_legendary():
	assert_eq(Util.get_quality_text(4), "Lengendary")

func test_get_quality_text_unknown_returns_empty():
	assert_eq(Util.get_quality_text(99), "")

# ----- find_tool_ids_in_data -----

func test_find_tool_ids_in_data_extracts_ids():
	var data := {"card_rose": true, "card_tulip": true, "other_key": false}
	var ids := Util.find_tool_ids_in_data(data)
	assert_true("rose" in ids)
	assert_true("tulip" in ids)
	assert_false("other_key" in ids)

func test_find_tool_ids_in_data_empty():
	var ids := Util.find_tool_ids_in_data({})
	assert_eq(ids.size(), 0)

func test_find_tool_ids_in_data_no_card_keys():
	var data := {"health": 10, "level": 2}
	var ids := Util.find_tool_ids_in_data(data)
	assert_eq(ids.size(), 0)

# ----- get_uuid -----

func test_get_uuid_returns_non_empty_string():
	var uuid := Util.get_uuid()
	assert_true(uuid.length() > 0)

func test_get_uuid_contains_underscore_separators():
	var uuid := Util.get_uuid()
	assert_true(uuid.contains("_"))

func test_get_uuid_is_unique():
	var uuid1 := Util.get_uuid()
	var uuid2 := Util.get_uuid()
	# UUIDs should almost never collide; this is a sanity check
	assert_ne(uuid1, uuid2)

# ----- get_action_id_with_action_type -----

func test_get_action_id_water():
	assert_eq(Util.get_action_id_with_action_type(ActionData.ActionType.WATER), "water")

func test_get_action_id_light():
	assert_eq(Util.get_action_id_with_action_type(ActionData.ActionType.LIGHT), "light")

func test_get_action_id_energy():
	assert_eq(Util.get_action_id_with_action_type(ActionData.ActionType.ENERGY), "energy")

func test_get_action_id_none_returns_empty():
	assert_eq(Util.get_action_id_with_action_type(ActionData.ActionType.NONE), "")

# ----- get_action_type_from_action_id -----

func test_get_action_type_from_id_water():
	assert_eq(Util.get_action_type_from_action_id("water"), ActionData.ActionType.WATER)

func test_get_action_type_from_id_light():
	assert_eq(Util.get_action_type_from_action_id("light"), ActionData.ActionType.LIGHT)

func test_get_action_type_from_id_roundtrip():
	var types := [
		ActionData.ActionType.WATER, ActionData.ActionType.LIGHT, ActionData.ActionType.PEST,
		ActionData.ActionType.ENERGY, ActionData.ActionType.DRAW_CARD, ActionData.ActionType.STUN,
		ActionData.ActionType.COMPOST, ActionData.ActionType.PUSH_LEFT, ActionData.ActionType.PUSH_RIGHT,
	]
	for action_type in types:
		var action_id := Util.get_action_id_with_action_type(action_type)
		var recovered := Util.get_action_type_from_action_id(action_id)
		assert_eq(recovered, action_type, "Roundtrip failed for type %s" % action_type)
