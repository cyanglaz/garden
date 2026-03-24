extends GutTest

func _make_trinket() -> PlayerTrinketEscapeWing:
	var t := PlayerTrinketEscapeWing.new()
	add_child_autofree(t)
	t.data = TrinketData.new()
	return t

# ----- has_damage_taken_hook -----

func test_has_damage_taken_hook_true_before_triggered() -> void:
	assert_true(_make_trinket().has_damage_taken_hook(null, 1))

func test_has_damage_taken_hook_false_after_triggered() -> void:
	var t := _make_trinket()
	t._triggered = true
	assert_false(t.has_damage_taken_hook(null, 1))

# ----- other hooks absent -----

func test_has_no_start_turn_hook() -> void:
	assert_false(_make_trinket().has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	assert_false(_make_trinket().has_end_turn_hook(null))

func test_has_no_exhaust_hook() -> void:
	assert_false(_make_trinket().has_exhaust_hook(null, []))

func test_has_no_discard_hook() -> void:
	assert_false(_make_trinket().has_discard_hook(null, []))

func test_has_no_draw_hook() -> void:
	assert_false(_make_trinket().has_draw_hook(null, []))
