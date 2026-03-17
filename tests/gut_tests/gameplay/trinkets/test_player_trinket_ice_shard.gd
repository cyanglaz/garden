extends GutTest

# ----- Helpers -----

func _make_trinket(water_value: int = 3) -> PlayerTrinketIceShard:
	var t := PlayerTrinketIceShard.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data["water"] = water_value
	t.data = td
	return t

# ----- has_end_turn_hook -----

func test_has_end_turn_hook_returns_true() -> void:
	var t := PlayerTrinketIceShard.new()
	add_child_autofree(t)
	assert_true(t.has_end_turn_hook(null))

func test_has_no_start_turn_hook() -> void:
	var t := PlayerTrinketIceShard.new()
	add_child_autofree(t)
	assert_false(t.has_start_turn_hook(null))
