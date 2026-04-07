extends GutTest

# ----- Stubs -----

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_trinket(energy_value: int = 3) -> PlayerTrinketFieldLog:
	var t := PlayerTrinketFieldLog.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"energy"] = str(energy_value)
	t.data = td
	return t

func _make_combat_main(field_index: int, max_idx: int, day: int = 1) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.day_manager.day = day
	var psc := PlayerStatusContainer.new()
	autofree(psc)
	var p := Player.new()
	autofree(p)
	p.player_status_container = psc
	p.max_plants_index = max_idx
	p.current_field_index = field_index
	cm.player = p
	return cm

# ----- has_player_move_hook -----

func test_has_hook_true_at_rightmost_plant() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(3, 3)
	assert_true(t.has_player_move_hook(cm))

func test_has_hook_false_at_non_rightmost_plant() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(1, 3)
	assert_false(t.has_player_move_hook(cm))

func test_has_hook_false_at_index_zero() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(0, 3)
	assert_false(t.has_player_move_hook(cm))

func test_has_hook_false_when_already_triggered() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(3, 3)
	t._triggered = true
	assert_false(t.has_player_move_hook(cm))

# ----- start_turn_hook (day 0 only) -----

func test_has_start_turn_hook_true_on_day_zero() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(1, 3, 0)
	assert_true(t.has_start_turn_hook(cm))

func test_has_start_turn_hook_false_when_day_not_zero() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(1, 3, 5)
	assert_false(t.has_start_turn_hook(cm))

func test_handle_start_turn_hook_sets_active_on_day_zero() -> void:
	var t := _make_trinket()
	var cm := _make_combat_main(1, 3, 0)
	t._handle_start_turn_hook(cm)
	assert_eq(t.data.state, TrinketData.TrinketState.ACTIVE)

# ----- handle_player_move_hook (state + hook animation) -----

func test_handle_player_move_hook_sets_state_normal() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.ACTIVE
	var cm := _make_combat_main(3, 3, 0)
	var saw_animation: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_animation[0] = true)
	t._handle_player_move_hook(cm)
	assert_eq(t.data.state, TrinketData.TrinketState.NORMAL)
	assert_true(t._triggered)
	assert_true(saw_animation[0])

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
