extends GutTest

# ----- Helpers -----

func _make_trinket() -> PlayerTrinketSilverThimble:
	var t := PlayerTrinketSilverThimble.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"draw"] = "1"
	td.data[&"discard"] = "1"
	t.data = td
	return t

# ----- has_hand_size_hook -----

func test_has_hand_size_hook_returns_true() -> void:
	var t := _make_trinket()
	assert_true(t.has_hand_size_hook(null))

# ----- has_start_turn_hook -----

func test_has_start_turn_hook_returns_true() -> void:
	var t := _make_trinket()
	assert_true(t.has_start_turn_hook(null))

# ----- has_end_turn_hook -----

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))
