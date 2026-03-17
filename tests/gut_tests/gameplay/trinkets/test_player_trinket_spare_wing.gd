extends GutTest

# ----- Stubs -----

class FakeStatusContainer:
	var _stacks: Dictionary = {}
	func get_player_upgrade_stack(id: String) -> int:
		return _stacks.get(id, 0)
	func set_player_upgrade(id: String, value: int) -> void:
		_stacks[id] = value

class FakePlayer:
	var player_status_container := FakeStatusContainer.new()
	var current_field_index: int = 0
	var max_plants_index: int = 3

class FakeCombatMain:
	var player := FakePlayer.new()

# ----- has_start_turn_hook -----

func test_has_hook_true_when_momentum_zero() -> void:
	var t := add_child_autofree(PlayerTrinketSpareWing.new())
	var cm := FakeCombatMain.new()
	# _stacks is empty so get("momentum", 0) == 0
	assert_true(t.has_start_turn_hook(cm))

func test_has_hook_false_when_momentum_nonzero() -> void:
	var t := add_child_autofree(PlayerTrinketSpareWing.new())
	var cm := FakeCombatMain.new()
	cm.player.player_status_container._stacks["momentum"] = 2
	assert_false(t.has_start_turn_hook(cm))

func test_has_no_end_turn_hook() -> void:
	var t := add_child_autofree(PlayerTrinketSpareWing.new())
	assert_false(t.has_end_turn_hook(null))

# ----- handle_start_turn_hook -----

func test_handle_sets_momentum_to_one() -> void:
	var t := add_child_autofree(PlayerTrinketSpareWing.new())
	var cm := FakeCombatMain.new()
	# momentum starts at 0, satisfying the assert inside the handler
	await t.handle_start_turn_hook(cm)
	assert_eq(cm.player.player_status_container._stacks.get("momentum"), 1)
