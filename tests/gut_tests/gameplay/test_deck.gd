extends GutTest

# Tests for Deck – the card pool manager used in combat.
# Deck is a pure RefCounted with no scene-tree dependencies.
# Items require get_duplicate() (ToolData satisfies this).

const FAKE_PATH := "res://fake/test_deck.tres"

func _make_tool(id_val: String = "test_fixture") -> ToolData:
	var td := ToolData.new()
	td.set("_original_resource_path", FAKE_PATH)
	td.id = id_val
	td.energy_cost = 1
	return td

func _make_deck(count: int = 3) -> Deck:
	# Items passed to Deck._init() are duplicated; must use "test_fixture" id
	# so the tool_script lookup succeeds (tool_script_test_fixture.gd exists).
	var items := []
	for _i in count:
		items.append(_make_tool("test_fixture"))
	return Deck.new(items)

# ----- _init -----

func test_init_pool_size_matches_input():
	var deck := _make_deck(3)
	assert_eq(deck.pool.size(), 3)

func test_init_draw_pool_size_matches_input():
	var deck := _make_deck(3)
	assert_eq(deck.draw_pool.size(), 3)

func test_init_hand_is_empty():
	var deck := _make_deck(3)
	assert_eq(deck.hand.size(), 0)

func test_init_discard_pool_is_empty():
	var deck := _make_deck(3)
	assert_eq(deck.discard_pool.size(), 0)

func test_init_exhaust_pool_is_empty():
	var deck := _make_deck(3)
	assert_eq(deck.exhaust_pool.size(), 0)

# ----- draw -----

func test_draw_moves_items_to_hand():
	var deck := _make_deck(3)
	deck.draw(2)
	assert_eq(deck.hand.size(), 2)

func test_draw_reduces_draw_pool():
	var deck := _make_deck(3)
	deck.draw(2)
	assert_eq(deck.draw_pool.size(), 1)

func test_draw_returns_drawn_items():
	var deck := _make_deck(3)
	var drawn := deck.draw(2)
	assert_eq(drawn.size(), 2)

func test_draw_from_empty_pool_returns_empty():
	var deck := _make_deck(0)
	var drawn := deck.draw(3)
	assert_eq(drawn.size(), 0)

func test_draw_more_than_pool_draws_all_available():
	var deck := _make_deck(2)
	deck.draw(10)
	assert_eq(deck.hand.size(), 2)
	assert_eq(deck.draw_pool.size(), 0)

# ----- shuffle_draw_pool -----

func test_shuffle_draw_pool_moves_discard_to_draw():
	var deck := _make_deck(3)
	# Manually populate discard_pool (bypass discard())
	var item := _make_tool("extra")
	deck.discard_pool.append(item)
	var draw_count_before := deck.draw_pool.size()
	deck.shuffle_draw_pool()
	assert_eq(deck.draw_pool.size(), draw_count_before + 1)

func test_shuffle_draw_pool_clears_discard():
	var deck := _make_deck(2)
	deck.discard_pool.append(_make_tool("extra"))
	deck.shuffle_draw_pool()
	assert_eq(deck.discard_pool.size(), 0)

# ----- refresh -----

func test_refresh_restores_draw_pool_to_full_size():
	var deck := _make_deck(3)
	deck.draw(3)
	deck.refresh()
	assert_eq(deck.draw_pool.size(), 3)

func test_refresh_clears_hand():
	var deck := _make_deck(3)
	deck.draw(2)
	deck.refresh()
	assert_eq(deck.hand.size(), 0)

func test_refresh_clears_discard_pool():
	var deck := _make_deck(3)
	deck.discard_pool.append(_make_tool("extra"))
	deck.refresh()
	assert_eq(deck.discard_pool.size(), 0)

func test_refresh_preserves_pool_size():
	var deck := _make_deck(4)
	deck.draw(2)
	deck.refresh()
	assert_eq(deck.pool.size(), 4)

# ----- add_items_to_draw_pile -----

func test_add_to_draw_pile_increases_pool():
	var deck := _make_deck(2)
	deck.add_items_to_draw_pile([_make_tool("new")])
	assert_eq(deck.pool.size(), 3)

func test_add_to_draw_pile_increases_draw_pool():
	var deck := _make_deck(2)
	deck.add_items_to_draw_pile([_make_tool("new")])
	assert_eq(deck.draw_pool.size(), 3)

func test_add_multiple_to_draw_pile():
	var deck := _make_deck(1)
	deck.add_items_to_draw_pile([_make_tool("a"), _make_tool("b")])
	assert_eq(deck.pool.size(), 3)
	assert_eq(deck.draw_pool.size(), 3)

# ----- add_items_discard_pile -----

func test_add_to_discard_pile_increases_pool():
	var deck := _make_deck(2)
	deck.add_items_discard_pile([_make_tool("new")])
	assert_eq(deck.pool.size(), 3)

func test_add_to_discard_pile_increases_discard_pool():
	var deck := _make_deck(2)
	deck.add_items_discard_pile([_make_tool("new")])
	assert_eq(deck.discard_pool.size(), 1)

# ----- add_items_to_hand -----

func test_add_to_hand_increases_hand():
	var deck := _make_deck(2)
	deck.add_items_to_hand([_make_tool("new")])
	assert_eq(deck.hand.size(), 1)

func test_add_to_hand_increases_pool():
	var deck := _make_deck(2)
	deck.add_items_to_hand([_make_tool("new")])
	assert_eq(deck.pool.size(), 3)

# ----- filter_items -----

func test_filter_items_removes_non_matching_from_draw_pool():
	var deck := _make_deck(0)
	var keep := _make_tool("keep")
	var drop := _make_tool("drop")
	deck.add_items_to_draw_pile([keep, drop])
	deck.filter_items(func(item: ToolData) -> bool: return item.id == "keep")
	assert_eq(deck.draw_pool.size(), 1)
	assert_true(keep in deck.draw_pool)

func test_filter_items_removes_non_matching_from_pool():
	var deck := _make_deck(0)
	var keep := _make_tool("keep")
	var drop := _make_tool("drop")
	deck.add_items_to_draw_pile([keep, drop])
	deck.filter_items(func(item: ToolData) -> bool: return item.id == "keep")
	assert_eq(deck.pool.size(), 1)

func test_filter_all_removes_everything():
	var deck := _make_deck(3)
	deck.filter_items(func(_item: ToolData) -> bool: return false)
	assert_eq(deck.draw_pool.size(), 0)
	assert_eq(deck.pool.size(), 0)

# ----- draw_specific -----

func test_draw_specific_draws_matching_items():
	var deck := _make_deck(0)
	var target := _make_tool("target")
	var other := _make_tool("other")
	deck.add_items_to_draw_pile([target, other], false)
	var drawn := deck.draw_specific(func(item: ToolData) -> bool: return item.id == "target")
	assert_eq(drawn.size(), 1)
	assert_true(target in drawn)

func test_draw_specific_removes_from_draw_pool():
	var deck := _make_deck(0)
	var target := _make_tool("target")
	deck.add_items_to_draw_pile([target], false)
	deck.draw_specific(func(item: ToolData) -> bool: return item.id == "target")
	assert_false(target in deck.draw_pool)

func test_draw_specific_adds_to_hand():
	var deck := _make_deck(0)
	var target := _make_tool("target")
	deck.add_items_to_draw_pile([target], false)
	deck.draw_specific(func(item: ToolData) -> bool: return item.id == "target")
	assert_true(target in deck.hand)

func test_draw_specific_no_match_returns_empty():
	var deck := _make_deck(3)
	var drawn := deck.draw_specific(func(_item: ToolData) -> bool: return false)
	assert_eq(drawn.size(), 0)
