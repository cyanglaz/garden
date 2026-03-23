extends GutTest

class FakeCombatMain extends CombatMain:
	pass

func _make_trinket() -> PlayerTrinketDewdropCoffee:
	var t := PlayerTrinketDewdropCoffee.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"energy"] = "1"
	td.data[&"turn"] = "1"
	t.data = td
	return t

func _make_combat_main(day: int) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = day
	return cm

# ----- has_start_turn_hook -----

func test_triggers_on_day_0() -> void:
	var t := _make_trinket()
	assert_true(t.has_start_turn_hook(_make_combat_main(0)))

func test_no_trigger_on_day_1() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(_make_combat_main(1)))

func test_no_trigger_on_day_5() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(_make_combat_main(5)))

# ----- other hooks absent -----

func test_has_no_draw_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_draw_hook(null, []))

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))
