extends GutTest

# ----- Stubs -----

class FakeStatusContainer:
	var last_id: String = ""
	var last_stack: int = 0
	var last_op: ActionData.OperatorType = ActionData.OperatorType.INCREASE
	func update_player_upgrade(id: String, stk: int, op: ActionData.OperatorType) -> void:
		last_id = id
		last_stack = stk
		last_op = op

class FakePlayer:
	var player_status_container := FakeStatusContainer.new()
	var current_field_index: int = 0
	var max_plants_index: int = 3

class FakeCombatMain:
	var player := FakePlayer.new()

# ----- has_draw_hook -----

func test_has_draw_hook_returns_true() -> void:
	var s := add_child_autofree(PlayerStatusOverclock.new())
	assert_true(s.has_draw_hook(null, []))

func test_has_draw_hook_true_with_non_empty_array() -> void:
	var s := add_child_autofree(PlayerStatusOverclock.new())
	assert_true(s.has_draw_hook(null, [ToolData.new()]))

# ----- handle_draw_hook -----
# PlayerActionApplier routes MOMENTUM to player_status_container.update_player_upgrade.
# Util.create_scaled_timer (used internally) resolves via the Singletons autoload,
# which is always present in GUT's scene tree.

func test_handle_draw_increases_momentum_by_stack_times_card_count() -> void:
	var s := add_child_autofree(PlayerStatusOverclock.new())
	var sd := StatusData.new()
	s.data = sd
	s.stack = 2
	var cm := FakeCombatMain.new()
	await s.handle_draw_hook(cm, [ToolData.new(), ToolData.new(), ToolData.new()])
	assert_eq(cm.player.player_status_container.last_stack, 6)
	assert_eq(cm.player.player_status_container.last_op, ActionData.OperatorType.INCREASE)

func test_handle_draw_scales_with_stack() -> void:
	var s := add_child_autofree(PlayerStatusOverclock.new())
	var sd := StatusData.new()
	s.data = sd
	s.stack = 3
	var cm := FakeCombatMain.new()
	await s.handle_draw_hook(cm, [ToolData.new(), ToolData.new()])
	assert_eq(cm.player.player_status_container.last_stack, 6)
