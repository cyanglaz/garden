extends GutTest

# ----- Helpers -----

func _make_trinket() -> PlayerTrinketNectarHeart:
	var t := PlayerTrinketNectarHeart.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"max_hp"] = "2"
	t.data = td
	return t

# ----- combat hooks absent -----

func test_has_no_start_turn_hook() -> void:
	assert_false(_make_trinket().has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	assert_false(_make_trinket().has_end_turn_hook(null))

func test_has_no_hand_updated_hook() -> void:
	assert_false(_make_trinket().has_hand_updated_hook(null))

func test_has_no_discard_hook() -> void:
	assert_false(_make_trinket().has_discard_hook(null, []))

func test_has_no_exhaust_hook() -> void:
	assert_false(_make_trinket().has_exhaust_hook(null, []))
