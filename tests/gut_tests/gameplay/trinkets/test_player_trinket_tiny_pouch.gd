extends GutTest

# ----- Stubs -----

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_trinket() -> PlayerTrinketTinyPouch:
	var t := PlayerTrinketTinyPouch.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"draw"] = "2"
	t.data = td
	return t

# ----- has_hand_size_hook -----

func test_has_hand_size_hook_true_on_turn_1() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 0
	assert_true(t.has_hand_size_hook(cm))

func test_has_hand_size_hook_false_after_turn_1() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 1
	assert_false(t.has_hand_size_hook(cm))

# ----- has_start_turn_hook -----

func test_has_no_start_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(null))

# ----- has_end_turn_hook -----

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))
