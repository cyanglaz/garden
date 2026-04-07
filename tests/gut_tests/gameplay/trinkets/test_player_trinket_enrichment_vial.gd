extends GutTest

class FakePlant extends Plant:
	func apply_actions(_actions: Array) -> void:
		pass

class FakeCombatMain extends CombatMain:
	var fake_plant: Plant = null
	func get_current_player_plant() -> Plant:
		return fake_plant

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

# ----- handle_discard_hook (state + hook animation) -----

func test_handle_discard_hook_sets_state_normal() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.ACTIVE
	var cm := _make_combat_main(0)
	var fp := FakePlant.new()
	autofree(fp)
	cm.fake_plant = fp
	var saw_animation: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_animation[0] = true)
	await t._handle_discard_hook(cm, [])
	assert_eq(t.data.state, TrinketData.TrinketState.NORMAL)
	assert_true(saw_animation[0])

# ----- start_turn_hook (ACTIVE state) -----

func test_has_start_turn_hook_always_true() -> void:
	var t := _make_trinket()
	assert_true(t.has_start_turn_hook(null))

func test_handle_start_turn_hook_sets_active() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(0)
	t._handle_start_turn_hook(cm)
	assert_eq(t.data.state, TrinketData.TrinketState.ACTIVE)

# ----- combat_end_hook -----

func test_has_combat_end_hook_always_true() -> void:
	var t := _make_trinket()
	assert_true(t.has_combat_end_hook(null))

func test_handle_combat_end_hook_sets_normal() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.ACTIVE
	t._handle_combat_end_hook(null)
	assert_eq(t.data.state, TrinketData.TrinketState.NORMAL)

# ----- other hooks absent -----

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))

func test_has_no_player_move_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_player_move_hook(null))
