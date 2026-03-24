extends GutTest

func _make_trinket() -> PlayerTrinketMixSprayer:
	var t := PlayerTrinketMixSprayer.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	t.data = td
	return t

# ----- has_exhaust_hook -----

func test_has_exhaust_hook_always_true() -> void:
	var t := _make_trinket()
	assert_true(t.has_exhaust_hook(null, []))

# ----- other hooks absent -----

func test_has_no_start_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))

func test_has_no_discard_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_discard_hook(null, []))

func test_has_no_draw_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_draw_hook(null, []))
