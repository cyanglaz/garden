extends GutTest

# ----- Helpers -----

func _make_trinket(pest: int = 2, fungus: int = 1) -> PlayerTrinketSaltGrinder:
	var t := PlayerTrinketSaltGrinder.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data["pest"] = pest
	td.data["fungus"] = fungus
	t.data = td
	return t

# ----- has_*_hook -----

func test_has_start_turn_hook_returns_true() -> void:
	var t := PlayerTrinketSaltGrinder.new()
	add_child_autofree(t)
	assert_true(t.has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	var t := PlayerTrinketSaltGrinder.new()
	add_child_autofree(t)
	assert_false(t.has_end_turn_hook(null))
