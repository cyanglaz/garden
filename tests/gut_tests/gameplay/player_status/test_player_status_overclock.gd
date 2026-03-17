extends GutTest

# ----- Stubs -----

class FakeStatusContainer extends PlayerStatusContainer:
	var last_id: String = ""
	var last_stack: int = 0
	var last_op: ActionData.OperatorType = ActionData.OperatorType.INCREASE
	func update_player_upgrade(id: String, stk: int, op: ActionData.OperatorType) -> void:
		last_id = id
		last_stack = stk
		last_op = op

class FakeCombatMain extends CombatMain:
	pass

# ----- has_draw_hook -----

func test_has_draw_hook_returns_true() -> void:
	var s := PlayerStatusOverclock.new()
	add_child_autofree(s)
	assert_true(s.has_draw_hook(null, []))

func test_has_draw_hook_true_with_non_empty_array() -> void:
	var s := PlayerStatusOverclock.new()
	add_child_autofree(s)
	assert_true(s.has_draw_hook(null, [ToolData.new()]))

# ----- handle_draw_hook -----
# PlayerActionApplier routes MOMENTUM to player_status_container.update_player_upgrade.
# Util.create_scaled_timer (used internally) resolves via the Singletons autoload,
# which is always present in GUT's scene tree.

func test_handle_draw_increases_momentum_by_stack_times_card_count() -> void:
	var s := PlayerStatusOverclock.new()
	add_child_autofree(s)
	var sd := StatusData.new()
	s.data = sd
	s.stack = 2
	var fake_sc := FakeStatusContainer.new()
	add_child_autofree(fake_sc)
	var p := Player.new()
	p.player_status_container = fake_sc
	var cm := FakeCombatMain.new()
	cm.player = p
	await s.handle_draw_hook(cm, [ToolData.new(), ToolData.new(), ToolData.new()])
	assert_eq(fake_sc.last_stack, 6)
	assert_eq(fake_sc.last_op, ActionData.OperatorType.INCREASE)

func test_handle_draw_scales_with_stack() -> void:
	var s := PlayerStatusOverclock.new()
	add_child_autofree(s)
	var sd := StatusData.new()
	s.data = sd
	s.stack = 3
	var fake_sc := FakeStatusContainer.new()
	add_child_autofree(fake_sc)
	var p := Player.new()
	p.player_status_container = fake_sc
	var cm := FakeCombatMain.new()
	cm.player = p
	await s.handle_draw_hook(cm, [ToolData.new(), ToolData.new()])
	assert_eq(fake_sc.last_stack, 6)
