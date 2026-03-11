extends GutTest

# Tests for ActionsApplier._organize_actions_to_apply().
# This is a pure algorithm that expands LOOP actions into repeated sub-arrays.
# No scene tree or CombatMain is needed.

func _make_action(type: ActionData.ActionType, value: int = 1) -> ActionData:
	var ad := ActionData.new()
	ad.type = type
	ad.value = value
	ad.value_type = ActionData.ValueType.NUMBER
	ad.operator_type = ActionData.OperatorType.INCREASE
	return ad

func _make_loop(loop_count: int) -> ActionData:
	return _make_action(ActionData.ActionType.LOOP, loop_count)

# Helper to get action types from result array
func _types(actions: Array) -> Array:
	var result := []
	for a: ActionData in actions:
		result.append(a.type)
	return result

# ----- no LOOP: returns duplicate of input -----

func test_no_loop_returns_same_count():
	var applier := ActionsApplier.new()
	var actions := [
		_make_action(ActionData.ActionType.WATER),
		_make_action(ActionData.ActionType.LIGHT),
	]
	var result := applier._organize_actions_to_apply(actions)
	assert_eq(result.size(), 2)

func test_no_loop_preserves_types():
	var applier := ActionsApplier.new()
	var actions := [
		_make_action(ActionData.ActionType.WATER),
		_make_action(ActionData.ActionType.LIGHT),
	]
	var result := applier._organize_actions_to_apply(actions)
	assert_eq(result[0].type, ActionData.ActionType.WATER)
	assert_eq(result[1].type, ActionData.ActionType.LIGHT)

func test_empty_input_returns_empty():
	var applier := ActionsApplier.new()
	var result := applier._organize_actions_to_apply([])
	assert_eq(result.size(), 0)

# ----- LOOP in the middle -----

func test_loop_value_2_doubles_preceding_actions():
	var applier := ActionsApplier.new()
	var actions := [
		_make_action(ActionData.ActionType.WATER),
		_make_action(ActionData.ActionType.LIGHT),
		_make_loop(2),
	]
	var result := applier._organize_actions_to_apply(actions)
	# [WATER, LIGHT] × 2 = [WATER, LIGHT, WATER, LIGHT]
	assert_eq(result.size(), 4)

func test_loop_repeats_actions_before_it():
	var applier := ActionsApplier.new()
	var actions := [
		_make_action(ActionData.ActionType.WATER),
		_make_loop(3),
		_make_action(ActionData.ActionType.ENERGY),
	]
	var result := applier._organize_actions_to_apply(actions)
	# [WATER] × 3 + [ENERGY] = 4 total
	assert_eq(result.size(), 4)
	assert_eq(result[0].type, ActionData.ActionType.WATER)
	assert_eq(result[1].type, ActionData.ActionType.WATER)
	assert_eq(result[2].type, ActionData.ActionType.WATER)
	assert_eq(result[3].type, ActionData.ActionType.ENERGY)

func test_loop_value_1_same_count_as_no_loop():
	var applier := ActionsApplier.new()
	var actions := [
		_make_action(ActionData.ActionType.WATER),
		_make_action(ActionData.ActionType.LIGHT),
		_make_loop(1),
	]
	var result := applier._organize_actions_to_apply(actions)
	# [WATER, LIGHT] × 1 = [WATER, LIGHT]
	assert_eq(result.size(), 2)

# ----- LOOP at the start -----

func test_loop_at_start_no_preceding_actions():
	var applier := ActionsApplier.new()
	var actions := [
		_make_loop(3),
		_make_action(ActionData.ActionType.ENERGY),
	]
	var result := applier._organize_actions_to_apply(actions)
	# nothing before LOOP × 3, then [ENERGY]
	assert_eq(result.size(), 1)
	assert_eq(result[0].type, ActionData.ActionType.ENERGY)

# ----- LOOP at the end -----

func test_loop_at_end_no_trailing_actions():
	var applier := ActionsApplier.new()
	var actions := [
		_make_action(ActionData.ActionType.WATER),
		_make_action(ActionData.ActionType.LIGHT),
		_make_loop(2),
	]
	var result := applier._organize_actions_to_apply(actions)
	# [WATER, LIGHT] × 2, nothing after
	assert_eq(result.size(), 4)

# ----- result is independent of input -----

func test_result_is_a_duplicate_not_same_reference():
	var applier := ActionsApplier.new()
	var water := _make_action(ActionData.ActionType.WATER)
	var actions := [water]
	var result := applier._organize_actions_to_apply(actions)
	result.append(_make_action(ActionData.ActionType.ENERGY))
	assert_eq(actions.size(), 1)  # original unchanged
