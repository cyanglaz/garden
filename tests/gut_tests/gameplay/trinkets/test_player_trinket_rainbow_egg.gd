extends GutTest

# ----- Stubs -----

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_trinket() -> PlayerTrinketRainbowEgg:
	var t := PlayerTrinketRainbowEgg.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"water"] = "2"
	td.data[&"light"] = "2"
	t.data = td
	return t

# ----- has_start_turn_hook -----

func test_has_hook_true_on_turn_6() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 5
	assert_true(t.has_start_turn_hook(cm))

func test_has_hook_false_before_turn_6() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 0
	assert_false(t.has_start_turn_hook(cm))

func test_has_hook_false_after_turn_6() -> void:
	var t := _make_trinket()
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = 6
	assert_false(t.has_start_turn_hook(cm))

# ----- other hooks absent -----

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))
