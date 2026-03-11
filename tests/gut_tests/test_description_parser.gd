extends GutTest

# Tests for DescriptionParser static methods that perform pure string parsing.

# ----- find_all_reference_pairs -----

func test_find_pairs_returns_empty_for_plain_string():
	var pairs := DescriptionParser.find_all_reference_pairs("No references here.")
	assert_eq(pairs.size(), 0)

func test_find_pairs_single_pair():
	var pairs := DescriptionParser.find_all_reference_pairs("Deal {action:water} damage.")
	assert_eq(pairs.size(), 1)
	assert_eq(pairs[0][0], "action")
	assert_eq(pairs[0][1], "water")

func test_find_pairs_multiple_pairs():
	var pairs := DescriptionParser.find_all_reference_pairs("{action:water} and {field_status:drowned}")
	assert_eq(pairs.size(), 2)
	assert_eq(pairs[0][0], "action")
	assert_eq(pairs[0][1], "water")
	assert_eq(pairs[1][0], "field_status")
	assert_eq(pairs[1][1], "drowned")

func test_find_pairs_ignores_entries_without_colon():
	# A {single} entry with no colon should be ignored (pair.size() != 2)
	var pairs := DescriptionParser.find_all_reference_pairs("{single}")
	assert_eq(pairs.size(), 0)

func test_find_pairs_empty_string():
	var pairs := DescriptionParser.find_all_reference_pairs("")
	assert_eq(pairs.size(), 0)

func test_find_pairs_pair_values_are_correct():
	var pairs := DescriptionParser.find_all_reference_pairs("Gain {resource:energy} each turn.")
	assert_eq(pairs.size(), 1)
	assert_eq(pairs[0][0], "resource")
	assert_eq(pairs[0][1], "energy")

func test_find_pairs_preserves_order():
	var pairs := DescriptionParser.find_all_reference_pairs("{a:1} {b:2} {c:3}")
	assert_eq(pairs.size(), 3)
	assert_eq(pairs[0][1], "1")
	assert_eq(pairs[1][1], "2")
	assert_eq(pairs[2][1], "3")

func test_find_pairs_adjacent_braces():
	var pairs := DescriptionParser.find_all_reference_pairs("{x:foo}{y:bar}")
	assert_eq(pairs.size(), 2)
	assert_eq(pairs[0][0], "x")
	assert_eq(pairs[1][0], "y")

func test_find_pairs_no_closing_brace_ignored():
	# Unclosed brace has no matching '}', so find() returns -1 and loop breaks.
	var pairs := DescriptionParser.find_all_reference_pairs("{unclosed:value")
	assert_eq(pairs.size(), 0)

func test_find_pairs_no_opening_brace():
	var pairs := DescriptionParser.find_all_reference_pairs("no:braces:here")
	assert_eq(pairs.size(), 0)

# ----- format_references: no-op cases -----

func test_format_references_plain_string_unchanged():
	var result := DescriptionParser.format_references("No references here.", {}, {}, func(_k): return false)
	assert_eq(result, "No references here.")

func test_format_references_empty_string_returns_empty():
	var result := DescriptionParser.format_references("", {}, {}, func(_k): return false)
	assert_eq(result, "")

func test_format_references_no_braces_unchanged():
	var result := DescriptionParser.format_references("Deal 3 damage.", {}, {}, func(_k): return false)
	assert_eq(result, "Deal 3 damage.")

# ----- format_references: single-part data substitution -----

func test_format_references_single_key_in_data_replaced():
	var result := DescriptionParser.format_references("Deal {val} damage.", {"val": "3"}, {}, func(_k): return false)
	assert_true(result.contains("3"))

func test_format_references_single_key_in_data_has_color_markup():
	var result := DescriptionParser.format_references("{val}", {"val": "3"}, {}, func(_k): return false)
	assert_true(result.contains("[color="))

func test_format_references_single_key_missing_from_data_is_removed():
	var result := DescriptionParser.format_references("A{missing}B", {}, {}, func(_k): return false)
	assert_eq(result, "AB")

# ----- format_references: icon reference categories (field_status / resource / action / power) -----

func test_format_references_field_status_produces_img_tag():
	var result := DescriptionParser.format_references("{field_status:pest}", {}, {}, func(_k): return false)
	assert_true(result.begins_with("[img=6x6]res://resources/sprites/GUI/icons/resources/icon_pest.png[/img]"))

func test_format_references_resource_produces_img_tag():
	var result := DescriptionParser.format_references("{resource:water}", {}, {}, func(_k): return false)
	assert_true(result.begins_with("[img=6x6]res://resources/sprites/GUI/icons/resources/icon_water.png[/img]"))

func test_format_references_action_produces_img_tag():
	var result := DescriptionParser.format_references("{action:light}", {}, {}, func(_k): return false)
	assert_true(result.begins_with("[img=6x6]res://resources/sprites/GUI/icons/resources/icon_light.png[/img]"))

func test_format_references_power_produces_img_tag():
	var result := DescriptionParser.format_references("{power:energy}", {}, {}, func(_k): return false)
	assert_true(result.begins_with("[img=6x6]res://resources/sprites/GUI/icons/resources/icon_energy.png[/img]"))

func test_format_references_icon_with_level_suffix_contains_suffix():
	var result := DescriptionParser.format_references("{resource:water+2}", {}, {}, func(_k): return false)
	assert_true(result.contains("[img=6x6]"))
	assert_true(result.contains("+2"))

func test_format_references_icon_base_path_is_correct_with_level_suffix():
	var result := DescriptionParser.format_references("{resource:water+2}", {}, {}, func(_k): return false)
	assert_true(result.contains("icon_water.png"))

# ----- format_references: sign category -----

func test_format_references_sign_plus_produces_exact_img_tag():
	var result := DescriptionParser.format_references("{sign:plus}", {}, {}, func(_k): return false)
	assert_eq(result, "[img=6x6]res://resources/sprites/GUI/icons/cards/signs/icon_plus.png[/img]")

func test_format_references_sign_minus_produces_exact_img_tag():
	var result := DescriptionParser.format_references("{sign:minus}", {}, {}, func(_k): return false)
	assert_eq(result, "[img=6x6]res://resources/sprites/GUI/icons/cards/signs/icon_minus.png[/img]")

func test_format_references_sign_equals_produces_exact_img_tag():
	var result := DescriptionParser.format_references("{sign:equals}", {}, {}, func(_k): return false)
	assert_eq(result, "[img=6x6]res://resources/sprites/GUI/icons/cards/signs/icon_equals.png[/img]")

# ----- format_references: value category -----

func test_format_references_value_digit_produces_exact_img_tag():
	var result := DescriptionParser.format_references("{value:5}", {}, {}, func(_k): return false)
	assert_eq(result, "[img=6x6]res://resources/sprites/GUI/icons/cards/values/icon_5.png[/img]")

func test_format_references_value_zero_produces_exact_img_tag():
	var result := DescriptionParser.format_references("{value:0}", {}, {}, func(_k): return false)
	assert_eq(result, "[img=6x6]res://resources/sprites/GUI/icons/cards/values/icon_0.png[/img]")

# ----- format_references: bordered_text category -----

func test_format_references_bordered_text_contains_text():
	var result := DescriptionParser.format_references("{bordered_text:Hello}", {}, {}, func(_k): return false)
	assert_true(result.contains("Hello"))

func test_format_references_bordered_text_has_color_markup():
	var result := DescriptionParser.format_references("{bordered_text:Hi}", {}, {}, func(_k): return false)
	assert_true(result.contains("[color="))

func test_format_references_bordered_text_has_outline_markup():
	var result := DescriptionParser.format_references("{bordered_text:Hi}", {}, {}, func(_k): return false)
	assert_true(result.contains("[outline_size="))

# ----- format_references: unknown category -----

func test_format_references_unknown_category_produces_empty():
	var result := DescriptionParser.format_references("{unknown:thing}", {}, {}, func(_k): return false)
	assert_eq(result, "")

func test_format_references_unknown_category_braces_removed_from_string():
	var result := DescriptionParser.format_references("A{unknown:x}B", {}, {}, func(_k): return false)
	assert_eq(result, "AB")

# ----- format_references: dt_ prefix -----

func test_format_references_dt_prefix_substitutes_id_from_data():
	var result := DescriptionParser.format_references("{bordered_text:dt_mykey}", {"mykey": "sub"}, {}, func(_k): return false)
	assert_true(result.contains("sub"))

func test_format_references_dt_prefix_on_icon_category_resolves_correctly():
	var result := DescriptionParser.format_references("{resource:dt_res}", {"res": "water"}, {}, func(_k): return false)
	assert_true(result.begins_with("[img=6x6]res://resources/sprites/GUI/icons/resources/icon_water.png[/img]"))

# ----- format_references: multiple references -----

func test_format_references_two_references_both_replaced():
	var result := DescriptionParser.format_references("{bordered_text:A} and {bordered_text:B}", {}, {}, func(_k): return false)
	assert_true(result.contains("A"))
	assert_true(result.contains("B"))

func test_format_references_mixed_text_and_reference():
	var result := DescriptionParser.format_references("Gain {bordered_text:3} energy.", {}, {}, func(_k): return false)
	assert_true(result.contains("3"))
	assert_true(result.contains("energy"))

func test_format_references_adjacent_references_both_present():
	var result := DescriptionParser.format_references("{bordered_text:X}{bordered_text:Y}", {}, {}, func(_k): return false)
	assert_true(result.contains("X"))
	assert_true(result.contains("Y"))

func test_format_references_icon_and_text_combined():
	var result := DescriptionParser.format_references("Add {resource:water} to {bordered_text:field}.", {}, {}, func(_k): return false)
	assert_true(result.contains("[img=6x6]"))
	assert_true(result.contains("field"))

# ----- format_references: additional_highlight_check -----

func test_format_references_highlight_check_true_changes_bordered_text_color():
	var normal := DescriptionParser.format_references("{bordered_text:text}", {}, {}, func(_k): return false)
	var highlighted := DescriptionParser.format_references("{bordered_text:text}", {}, {}, func(_k): return true)
	assert_ne(normal, highlighted)
	assert_true(highlighted.contains("text"))

# ----- format_references: highlight_description_keys -----

func test_format_references_highlight_key_match_changes_bordered_text_color():
	var normal := DescriptionParser.format_references("{bordered_text:pest}", {}, {}, func(_k): return false)
	var highlighted := DescriptionParser.format_references("{bordered_text:pest}", {}, {"pest": true}, func(_k): return false)
	assert_ne(normal, highlighted)

func test_format_references_icon_reference_still_has_img_tag_when_key_highlighted():
	var result := DescriptionParser.format_references("{field_status:pest}", {}, {"pest": true}, func(_k): return false)
	assert_true(result.contains("[img=6x6]"))

# ----- format_references: custom highlight_color -----

func test_format_references_custom_highlight_color_affects_single_key_output():
	var white_result := DescriptionParser.format_references("{val}", {"val": "x"}, {}, func(_k): return false, Color.WHITE)
	var red_result := DescriptionParser.format_references("{val}", {"val": "x"}, {}, func(_k): return false, Color.RED)
	assert_ne(white_result, red_result)
