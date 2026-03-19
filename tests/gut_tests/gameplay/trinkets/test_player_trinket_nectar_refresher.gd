extends GutTest

# ----- Stubs -----

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_trinket() -> PlayerTrinketNectarRefresher:
	var t := PlayerTrinketNectarRefresher.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"momentum"] = "3"
	t.data = td
	return t

# ----- has_start_turn_hook -----

func test_has_hook_true_on_turn_3() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 2
	assert_true(t.has_start_turn_hook(cm))

func test_has_hook_false_on_other_turn() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 0
	assert_false(t.has_start_turn_hook(cm))

# ----- has_end_turn_hook -----

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))
