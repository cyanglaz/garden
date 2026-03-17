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

func _make_status(value: int, stack_count: int) -> PlayerStatusContrail:
	var s := add_child_autofree(PlayerStatusContrail.new())
	var sd := StatusData.new()
	sd.data["value"] = value
	s.data = sd
	s.stack = stack_count
	return s

# ----- has_player_move_hook -----

func test_has_player_move_hook_returns_true() -> void:
	var s := add_child_autofree(PlayerStatusContrail.new())
	assert_true(s.has_player_move_hook(null))

# ----- handle_player_move_hook -----

func test_handle_applies_water_increase() -> void:
	var s := _make_status(3, 2)
	var cm := FakeCombatMain.new()
	await s.handle_player_move_hook(cm)
	assert_eq(cm._plant.last_actions[0].type, ActionData.ActionType.WATER)
	assert_eq(cm._plant.last_actions[0].operator_type, ActionData.OperatorType.INCREASE)

func test_handle_water_value_is_stack_times_data_value() -> void:
	var s := _make_status(3, 2)
	var cm := FakeCombatMain.new()
	await s.handle_player_move_hook(cm)
	assert_eq(cm._plant.last_actions[0].value, 6)
