extends GutTest

# ----- Stubs -----

class FakePlant:
	var last_actions: Array = []
	func apply_actions(actions: Array) -> void:
		last_actions = actions

class FakeCombatMain:
	var _plant := FakePlant.new()
	func get_current_player_plant() -> FakePlant:
		return _plant

# ----- Helpers -----

func _make_status(value: int, stack: int) -> PlayerStatusRegenerator:
	var s := add_child_autofree(PlayerStatusRegenerator.new())
	var sd := StatusData.new()
	sd.data["value"] = value
	s.data = sd
	s.stack = stack
	return s

# ----- has_stack_update_hook -----

func test_has_hook_true_for_momentum_negative_diff() -> void:
	var s := add_child_autofree(PlayerStatusRegenerator.new())
	assert_true(s.has_stack_update_hook(null, "momentum", -1))

func test_has_hook_false_for_momentum_zero_diff() -> void:
	var s := add_child_autofree(PlayerStatusRegenerator.new())
	assert_false(s.has_stack_update_hook(null, "momentum", 0))

func test_has_hook_false_for_momentum_positive_diff() -> void:
	var s := add_child_autofree(PlayerStatusRegenerator.new())
	assert_false(s.has_stack_update_hook(null, "momentum", 1))

func test_has_hook_false_for_other_status_negative_diff() -> void:
	var s := add_child_autofree(PlayerStatusRegenerator.new())
	assert_false(s.has_stack_update_hook(null, "water", -1))

# ----- handle_stack_update_hook -----

func test_handle_applies_light_increase() -> void:
	var s := _make_status(3, 2)
	var cm := FakeCombatMain.new()
	await s.handle_stack_update_hook(cm, "momentum", -1)
	assert_eq(cm._plant.last_actions[0].type, ActionData.ActionType.LIGHT)
	assert_eq(cm._plant.last_actions[0].operator_type, ActionData.OperatorType.INCREASE)

func test_handle_light_value_is_stack_times_data_value() -> void:
	var s := _make_status(3, 2)
	var cm := FakeCombatMain.new()
	await s.handle_stack_update_hook(cm, "momentum", -1)
	assert_eq(cm._plant.last_actions[0].value, 6)
