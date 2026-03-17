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

func _make_status(value: int, stack_count: int) -> PlayerStatusCondensation:
	var s := add_child_autofree(PlayerStatusCondensation.new())
	var sd := StatusData.new()
	sd.data["value"] = value
	s.data = sd
	s.stack = stack_count
	return s

# ----- has_discard_hook -----

func test_has_discard_hook_returns_true() -> void:
	var s := add_child_autofree(PlayerStatusCondensation.new())
	assert_true(s.has_discard_hook(null, []))

func test_has_discard_hook_true_with_cards() -> void:
	var s := add_child_autofree(PlayerStatusCondensation.new())
	assert_true(s.has_discard_hook(null, [ToolData.new(), ToolData.new()]))

# ----- handle_discard_hook -----

func test_handle_applies_water_increase() -> void:
	var s := _make_status(3, 2)
	var cm := FakeCombatMain.new()
	await s.handle_discard_hook(cm, [ToolData.new()])
	assert_eq(cm._plant.last_actions[0].type, ActionData.ActionType.WATER)
	assert_eq(cm._plant.last_actions[0].operator_type, ActionData.OperatorType.INCREASE)

func test_handle_water_value_is_value_times_stack_times_card_count() -> void:
	# value=3, stack=2, 2 cards discarded → 3 * 2 * 2 = 12
	var s := _make_status(3, 2)
	var cm := FakeCombatMain.new()
	await s.handle_discard_hook(cm, [ToolData.new(), ToolData.new()])
	assert_eq(cm._plant.last_actions[0].value, 12)

func test_handle_water_value_scales_with_card_count() -> void:
	var s := _make_status(2, 1)
	var cm := FakeCombatMain.new()
	await s.handle_discard_hook(cm, [ToolData.new(), ToolData.new(), ToolData.new()])
	assert_eq(cm._plant.last_actions[0].value, 6)
