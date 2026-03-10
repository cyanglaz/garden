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
