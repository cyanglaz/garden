extends GutTest

# Tests for CardActionApplier.apply_action().
# Covers UPDATE_X type with INCREASE / DECREASE / EQUAL_TO operators.
# No scene tree or CombatMain needed.

func _make_update_x_action(operator: ActionData.OperatorType, value: int) -> ActionData:
	var ad := ActionData.new()
	ad.type = ActionData.ActionType.UPDATE_X
	# action_category is computed from type: UPDATE_X → CARD (no setter needed)
	ad.operator_type = operator
	ad.value = value
	ad.value_type = ActionData.ValueType.NUMBER
	return ad

func _make_x_action() -> ActionData:
	var ad := ActionData.new()
	ad.value_type = ActionData.ValueType.X
	ad.modified_x_value = 0
	return ad

# ----- INCREASE -----

func test_increase_adds_value_to_modified_x_value():
	var applier := CardActionApplier.new()
	var x_action := _make_x_action()
	x_action.modified_x_value = 5
	var update := _make_update_x_action(ActionData.OperatorType.INCREASE, 3)
	applier.apply_action(update, [x_action])
	assert_eq(x_action.modified_x_value, 8)

func test_increase_from_zero():
	var applier := CardActionApplier.new()
	var x_action := _make_x_action()
	var update := _make_update_x_action(ActionData.OperatorType.INCREASE, 4)
	applier.apply_action(update, [x_action])
	assert_eq(x_action.modified_x_value, 4)

func test_increase_finds_x_action_among_multiple():
	var applier := CardActionApplier.new()
	var non_x := ActionData.new()
	non_x.value_type = ActionData.ValueType.NUMBER
	var x_action := _make_x_action()
	var update := _make_update_x_action(ActionData.OperatorType.INCREASE, 2)
	applier.apply_action(update, [non_x, x_action])
	assert_eq(x_action.modified_x_value, 2)

# ----- DECREASE -----

func test_decrease_subtracts_value_from_modified_x_value():
	var applier := CardActionApplier.new()
	var x_action := _make_x_action()
	x_action.modified_x_value = 10
	var update := _make_update_x_action(ActionData.OperatorType.DECREASE, 3)
	applier.apply_action(update, [x_action])
	assert_eq(x_action.modified_x_value, 7)

func test_decrease_can_result_in_negative():
	var applier := CardActionApplier.new()
	var x_action := _make_x_action()
	x_action.modified_x_value = 2
	var update := _make_update_x_action(ActionData.OperatorType.DECREASE, 5)
	applier.apply_action(update, [x_action])
	assert_eq(x_action.modified_x_value, -3)

# ----- EQUAL_TO -----

func test_equal_to_sets_exact_value():
	var applier := CardActionApplier.new()
	var x_action := _make_x_action()
	x_action.modified_x_value = 99
	var update := _make_update_x_action(ActionData.OperatorType.EQUAL_TO, 7)
	applier.apply_action(update, [x_action])
	assert_eq(x_action.modified_x_value, 7)

func test_equal_to_zero():
	var applier := CardActionApplier.new()
	var x_action := _make_x_action()
	x_action.modified_x_value = 50
	var update := _make_update_x_action(ActionData.OperatorType.EQUAL_TO, 0)
	applier.apply_action(update, [x_action])
	assert_eq(x_action.modified_x_value, 0)
