extends GutTest

class FakeCombatMain extends CombatMain:
	pass

func _make_trinket() -> PlayerTrinketEnrichmentVial:
	var t := PlayerTrinketEnrichmentVial.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"light"] = "1"
	td.data[&"water"] = "1"
	t.data = td
	return t

func _make_combat_main(day: int) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = day
	return cm

# ----- has_discard_hook -----

func test_has_discard_hook_true_on_fresh_trinket() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(0)
	assert_true(t.has_discard_hook(cm, []))

func test_has_discard_hook_false_after_triggered_same_turn() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(0)
	t._last_triggered_turn = 0
	assert_false(t.has_discard_hook(cm, []))

func test_has_discard_hook_true_on_new_turn() -> void:
	var t := _make_trinket()
	t._last_triggered_turn = 0
	var cm := _make_combat_main(1)
	assert_true(t.has_discard_hook(cm, []))

# ----- other hooks absent -----

func test_has_no_start_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_start_turn_hook(null))

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))

func test_has_no_player_move_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_player_move_hook(null))
