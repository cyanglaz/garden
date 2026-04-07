extends GutTest

class FakePlayerStatusContainerDraw extends PlayerStatusContainer:
	func update_player_upgrade(_id: String, _stack: int, _operator_type: ActionData.OperatorType) -> void:
		pass

class FakeCombatMain extends CombatMain:
	pass

func _make_trinket() -> PlayerTrinketDraftingPetal:
	var t := PlayerTrinketDraftingPetal.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"momentum"] = "1"
	t.data = td
	return t

func _make_combat_main(day: int, mid_turn: bool) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = day
	cm.is_mid_turn = mid_turn
	return cm

# ----- has_draw_hook -----

func test_has_draw_hook_false_during_start_of_turn_draw() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(0, false)
	assert_false(t.has_draw_hook(cm, []))

func test_has_draw_hook_true_during_mid_turn() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(0, true)
	assert_true(t.has_draw_hook(cm, []))

func test_has_draw_hook_false_after_triggered_same_turn() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(0, true)
	t._last_triggered_turn = 0
	assert_false(t.has_draw_hook(cm, []))

func test_has_draw_hook_true_on_new_turn() -> void:
	var t := _make_trinket()
	t._last_triggered_turn = 0
	var cm := _make_combat_main(1, true)
	assert_true(t.has_draw_hook(cm, []))

# ----- handle_draw_hook (state + hook animation) -----

func test_handle_draw_hook_sets_state_normal() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.ACTIVE
	var cm := _make_combat_main(0, true)
	var psc := FakePlayerStatusContainerDraw.new()
	autofree(psc)
	var p := Player.new()
	autofree(p)
	p.player_status_container = psc
	cm.player = p
	var saw_animation: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_animation[0] = true)
	t._handle_draw_hook(cm, [])
	assert_eq(t.data.state, TrinketData.TrinketState.NORMAL)
	assert_true(saw_animation[0])

# ----- start_turn_hook (ACTIVE state) -----

func test_has_start_turn_hook_always_true() -> void:
	var t := _make_trinket()
	assert_true(t.has_start_turn_hook(null))

func test_handle_start_turn_hook_sets_active() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(0, false)
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

func test_has_no_discard_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_discard_hook(null, []))
