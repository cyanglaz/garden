extends GutTest

# ----- Stubs -----

class FakePlayerStatusContainer extends PlayerStatusContainer:
	var _stacks: Dictionary = {}
	func get_player_upgrade_stack(id: String) -> int:
		return _stacks.get(id, 0)
	func update_player_upgrade(id: String, amount: int, _op: ActionData.OperatorType) -> void:
		_stacks[id] = _stacks.get(id, 0) + amount

class FakeCombatMain extends CombatMain:
	pass

# ----- Helpers -----

func _make_trinket() -> PlayerTrinketConservationCoil:
	var t := PlayerTrinketConservationCoil.new()
	add_child_autofree(t)
	var td := TrinketData.new()
	td.data[&"cards_played"] = "3"
	td.data[&"free_move"] = "1"
	t.data = td
	return t

func _make_combat_main() -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	var psc := FakePlayerStatusContainer.new()
	autofree(psc)
	var p := Player.new()
	autofree(p)
	p.player_status_container = psc
	cm.player = p
	return cm

# ----- has_start_turn_hook -----

func test_has_start_turn_hook_always_true() -> void:
	var t := _make_trinket()
	assert_true(t.has_start_turn_hook(null))

# ----- _handle_start_turn_hook -----

func test_handle_start_turn_hook_primes_active_when_normal() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.NORMAL
	var cm := _make_combat_main()
	t._handle_start_turn_hook(cm)
	assert_eq(t.data.state, TrinketData.TrinketState.ACTIVE)

func test_handle_start_turn_hook_resets_stack() -> void:
	var t := _make_trinket()
	(t.data as TrinketData).stack = 2
	var cm := _make_combat_main()
	t._handle_start_turn_hook(cm)
	assert_eq((t.data as TrinketData).stack, 3)

func test_handle_start_turn_hook_does_not_grant_free_move_on_first_turn() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.NORMAL
	var cm := _make_combat_main()
	t._handle_start_turn_hook(cm)
	var psc := cm.player.player_status_container as FakePlayerStatusContainer
	assert_eq(psc.get_player_upgrade_stack("free_move"), 0)

func test_handle_start_turn_hook_grants_free_move_when_active() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.ACTIVE
	var cm := _make_combat_main()
	t._handle_start_turn_hook(cm)
	var psc := cm.player.player_status_container as FakePlayerStatusContainer
	assert_eq(psc.get_player_upgrade_stack("free_move"), 1)

func test_handle_start_turn_hook_re_primes_active_after_granting_free_move() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.ACTIVE
	var cm := _make_combat_main()
	t._handle_start_turn_hook(cm)
	assert_eq(t.data.state, TrinketData.TrinketState.ACTIVE)

func test_handle_start_turn_hook_emits_animation_only_when_active() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.ACTIVE
	var cm := _make_combat_main()
	var saw_anim: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	t._handle_start_turn_hook(cm)
	assert_true(saw_anim[0])

func test_handle_start_turn_hook_no_animation_when_normal() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.NORMAL
	var cm := _make_combat_main()
	var saw_anim: Array = [false]
	t.request_player_upgrade_hook_animation.connect(func(_id: String) -> void: saw_anim[0] = true)
	t._handle_start_turn_hook(cm)
	assert_false(saw_anim[0])

# ----- has_tool_application_hook -----

func test_has_tool_application_hook_always_true() -> void:
	var t := _make_trinket()
	assert_true(t.has_tool_application_hook(null, null))

# ----- _handle_tool_application_hook -----

func test_handle_tool_application_hook_decrements_stack() -> void:
	var t := _make_trinket()
	(t.data as TrinketData).stack = 3
	t._handle_tool_application_hook(null, null)
	assert_eq((t.data as TrinketData).stack, 2)

func test_handle_tool_application_hook_does_not_deactivate_below_threshold() -> void:
	var t := _make_trinket()
	(t.data as TrinketData).stack = 3
	t.data.state = TrinketData.TrinketState.ACTIVE
	t._handle_tool_application_hook(null, null)
	t._handle_tool_application_hook(null, null)
	assert_eq(t.data.state, TrinketData.TrinketState.ACTIVE)

func test_handle_tool_application_hook_deactivates_at_threshold() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.ACTIVE
	t._handle_tool_application_hook(null, null)
	t._handle_tool_application_hook(null, null)
	t._handle_tool_application_hook(null, null)
	assert_eq(t.data.state, TrinketData.TrinketState.NORMAL)

# ----- has_combat_end_hook -----

func test_has_combat_end_hook_always_true() -> void:
	var t := _make_trinket()
	assert_true(t.has_combat_end_hook(null))

# ----- _handle_combat_end_hook -----

func test_handle_combat_end_hook_sets_state_normal() -> void:
	var t := _make_trinket()
	t.data.state = TrinketData.TrinketState.ACTIVE
	t._handle_combat_end_hook(null)
	assert_eq(t.data.state, TrinketData.TrinketState.NORMAL)

func test_handle_combat_end_hook_resets_stack() -> void:
	var t := _make_trinket()
	(t.data as TrinketData).stack = 2
	t._handle_combat_end_hook(null)
	assert_eq((t.data as TrinketData).stack, 0)

# ----- absent hooks -----

func test_has_no_end_turn_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_end_turn_hook(null))

func test_has_no_draw_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_draw_hook(null, []))

func test_has_no_discard_hook() -> void:
	var t := _make_trinket()
	assert_false(t.has_discard_hook(null, []))
