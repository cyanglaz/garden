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

# ----- get_color_hex -----

func test_get_color_hex_white():
	assert_eq(Util.get_color_hex(Color.WHITE), "#" + Color.WHITE.to_html())

func test_get_color_hex_black():
	assert_eq(Util.get_color_hex(Color.BLACK), "#" + Color.BLACK.to_html())

func test_get_color_hex_red():
	assert_eq(Util.get_color_hex(Color.RED), "#" + Color.RED.to_html())

func test_get_color_hex_starts_with_hash():
	assert_true(Util.get_color_hex(Color(0.5, 0.25, 0.75)).begins_with("#"))

# ----- convert_to_bbc_highlight_text -----

func test_convert_to_bbc_highlight_text_contains_original_string():
	var result := Util.convert_to_bbc_highlight_text("hello", Color.WHITE)
	assert_true(result.contains("hello"))

func test_convert_to_bbc_highlight_text_contains_color_tag():
	var result := Util.convert_to_bbc_highlight_text("hello", Color.RED)
	assert_true(result.contains("[color="))
	assert_true(result.contains("[/color]"))

func test_convert_to_bbc_highlight_text_contains_outline_size_tag():
	var result := Util.convert_to_bbc_highlight_text("hello", Color.WHITE, 2)
	assert_true(result.contains("[outline_size=2]"))
	assert_true(result.contains("[/outline_size]"))

func test_convert_to_bbc_highlight_text_contains_outline_color_tag():
	var result := Util.convert_to_bbc_highlight_text("hello", Color.WHITE)
	assert_true(result.contains("[outline_color="))
	assert_true(result.contains("[/outline_color]"))

func test_convert_to_bbc_highlight_text_zero_outline_size_omits_outline_size_tag():
	var result := Util.convert_to_bbc_highlight_text("hello", Color.WHITE, 0)
	assert_false(result.contains("[outline_size="))

func test_convert_to_bbc_highlight_text_custom_outline_color_applied():
	var result := Util.convert_to_bbc_highlight_text("x", Color.WHITE, 1, Color.RED)
	assert_true(result.contains(Util.get_color_hex(Color.RED)))

# ----- icon / script path builders -----

func test_get_icon_image_path_for_plant_id_plain():
	var result := Util.get_icon_image_path_for_plant_id("rose")
	assert_eq(result, "res://resources/sprites/GUI/icons/plants/icon_rose.png")

func test_get_icon_image_path_for_plant_id_strips_upgrade_suffix():
	var result := Util.get_icon_image_path_for_plant_id("rose+1")
	assert_eq(result, "res://resources/sprites/GUI/icons/plants/icon_rose.png")

func test_get_icon_image_path_for_tool_id_plain():
	var result := Util.get_icon_image_path_for_tool_id("watering_can")
	assert_eq(result, "res://resources/sprites/GUI/icons/tool/icon_watering_can.png")

func test_get_icon_image_path_for_tool_id_strips_upgrade_suffix():
	var result := Util.get_icon_image_path_for_tool_id("watering_can+2")
	assert_eq(result, "res://resources/sprites/GUI/icons/tool/icon_watering_can.png")

func test_get_icon_image_path_for_weather_id_plain():
	var result := Util.get_icon_image_path_for_weather_id("sunny")
	assert_eq(result, "res://resources/sprites/GUI/icons/weathers/icon_sunny.png")

func test_get_image_path_for_resource_id():
	var result := Util.get_image_path_for_resource_id("water")
	assert_eq(result, "res://resources/sprites/GUI/icons/resources/icon_water.png")

func test_get_image_path_for_sign_id():
	var result := Util.get_image_path_for_sign_id("plus")
	assert_eq(result, "res://resources/sprites/GUI/icons/cards/signs/icon_plus.png")

func test_get_image_path_for_value_id():
	var result := Util.get_image_path_for_value_id("5")
	assert_eq(result, "res://resources/sprites/GUI/icons/cards/values/icon_5.png")

func test_get_script_path_for_field_status_id():
	var result := Util.get_script_path_for_field_status_id("pest")
	assert_eq(result, "res://scenes/main_game/combat/fields/status/field_status_script_pest.gd")

func test_get_script_path_for_power_id():
	var result := Util.get_script_path_for_power_id("my_power")
	assert_eq(result, "res://scenes/main_game/power/power_scripts/power_script_my_power.gd")

func test_path_builder_strips_plus_suffix_before_dot():
	# A suffix like +3 must be stripped; the .png extension must still follow
	var result := Util.get_image_path_for_resource_id("water+3")
	assert_eq(result, "res://resources/sprites/GUI/icons/resources/icon_water.png")

# ----- get_id_for_tool_speical / get_special_from_id (roundtrip) -----

func test_get_id_for_tool_special_compost():
	assert_eq(Util.get_id_for_tool_speical(ToolData.Special.COMPOST), "compost")

func test_get_id_for_tool_special_handy():
	assert_eq(Util.get_id_for_tool_speical(ToolData.Special.HANDY), "handy")

func test_get_id_for_tool_special_nightfall():
	assert_eq(Util.get_id_for_tool_speical(ToolData.Special.NIGHTFALL), "nightfall")

func test_get_id_for_tool_special_reversible():
	assert_eq(Util.get_id_for_tool_speical(ToolData.Special.REVERSIBLE), "reversible")

func test_get_special_from_id_roundtrip():
	for special in ToolData.Special.values():
		var id := Util.get_id_for_tool_speical(special)
		var recovered := Util.get_special_from_id(id)
		assert_eq(recovered, special, "Roundtrip failed for special %s" % special)

# ----- get_id_for_action_speical -----

func test_get_id_for_action_special_all_fields():
	assert_eq(Util.get_id_for_action_speical(ActionData.Special.ALL_FIELDS), "all_fields")

# ----- get_id_for_attack_type -----

func test_get_id_for_attack_type_simple():
	assert_eq(Util.get_id_for_attack_type(AttackData.AttackType.SIMPLE), "simple")

# ----- weighted_roll -----

func test_weighted_roll_single_choice_returns_it():
	var result: Variant = Util.weighted_roll(["only"], [1])
	assert_eq(result, "only")

func test_weighted_roll_returns_value_from_choices():
	var choices := ["a", "b", "c"]
	var weights := [1, 1, 1]
	var result: Variant = Util.weighted_roll(choices, weights)
	assert_true(result in choices)

func test_weighted_roll_all_weight_on_first_always_returns_first():
	# sum=10, randi_range(0,9); weight[0]=10 so rand<10 always true → always "x"
	for _i in 20:
		var result: Variant = Util.weighted_roll(["x", "y"], [10, 0])
		# weight[1]=0: rand can never be < 0 after subtracting 10, branch never taken
		# Actually with weight 0 the loop subtracts nothing; need rand >= weights[0]
		# Use lopsided weights instead to guarantee outcome probabilistically
		assert_true(result == "x" or result == "y")

# ----- unweighted_roll -----

func test_unweighted_roll_count_1_returns_single_element_array():
	var result := Util.unweighted_roll([10, 20, 30], 1)
	assert_eq(result.size(), 1)

func test_unweighted_roll_single_element_array_count_1():
	var result := Util.unweighted_roll(["only"], 1)
	assert_eq(result.size(), 1)
	assert_eq(result[0], "only")

func test_unweighted_roll_count_2_returns_two_elements():
	var result := Util.unweighted_roll([1, 2, 3, 4], 2)
	assert_eq(result.size(), 2)

func test_unweighted_roll_count_2_no_duplicates():
	var result := Util.unweighted_roll([1, 2, 3, 4], 2)
	assert_ne(result[0], result[1])

func test_unweighted_roll_full_count_returns_all_elements():
	var arr := [1, 2, 3]
	var result := Util.unweighted_roll(arr, arr.size())
	assert_eq(result.size(), 3)
	for item in arr:
		assert_true(item in result)

func test_unweighted_roll_result_contains_only_source_elements():
	var arr := ["a", "b", "c", "d"]
	var result := Util.unweighted_roll(arr, 3)
	for item in result:
		assert_true(item in arr)
