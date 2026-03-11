extends GutTest

# Tests for ActionData – the data model for individual card actions.

const FAKE_PATH := "res://fake/test_action.tres"

func _make_action(action_type: ActionData.ActionType = ActionData.ActionType.WATER) -> ActionData:
	var ad := ActionData.new()
	ad.set("_original_resource_path", FAKE_PATH)
	ad.type = action_type
	ad.value = 0
	ad.x_value = 0
	return ad

# ----- _get_action_category -----

func test_action_category_field_for_water():
	var ad := _make_action(ActionData.ActionType.WATER)
	assert_eq(ad.action_category, ActionData.ActionCategory.FIELD)

func test_action_category_field_for_light():
	var ad := _make_action(ActionData.ActionType.LIGHT)
	assert_eq(ad.action_category, ActionData.ActionCategory.FIELD)

func test_action_category_field_for_pest():
	var ad := _make_action(ActionData.ActionType.PEST)
	assert_eq(ad.action_category, ActionData.ActionCategory.FIELD)

func test_action_category_field_for_fungus():
	var ad := _make_action(ActionData.ActionType.FUNGUS)
	assert_eq(ad.action_category, ActionData.ActionCategory.FIELD)

func test_action_category_field_for_recycle():
	var ad := _make_action(ActionData.ActionType.RECYCLE)
	assert_eq(ad.action_category, ActionData.ActionCategory.FIELD)

func test_action_category_player_for_energy():
	var ad := _make_action(ActionData.ActionType.ENERGY)
	assert_eq(ad.action_category, ActionData.ActionCategory.PLAYER)

func test_action_category_player_for_draw_card():
	var ad := _make_action(ActionData.ActionType.DRAW_CARD)
	assert_eq(ad.action_category, ActionData.ActionCategory.PLAYER)

func test_action_category_player_for_update_hp():
	var ad := _make_action(ActionData.ActionType.UPDATE_HP)
	assert_eq(ad.action_category, ActionData.ActionCategory.PLAYER)

func test_action_category_player_for_momentum():
	var ad := _make_action(ActionData.ActionType.MOMENTUM)
	assert_eq(ad.action_category, ActionData.ActionCategory.PLAYER)

func test_action_category_card_for_update_x():
	var ad := _make_action(ActionData.ActionType.UPDATE_X)
	assert_eq(ad.action_category, ActionData.ActionCategory.CARD)

func test_action_category_card_for_loop():
	var ad := _make_action(ActionData.ActionType.LOOP)
	assert_eq(ad.action_category, ActionData.ActionCategory.CARD)

func test_action_category_none_for_none_type():
	var ad := _make_action(ActionData.ActionType.NONE)
	assert_eq(ad.action_category, ActionData.ActionCategory.NONE)

# ----- _get_need_card_selection -----

func test_need_card_selection_true_for_discard():
	var ad := _make_action(ActionData.ActionType.DISCARD_CARD)
	assert_true(ad.need_card_selection)

func test_need_card_selection_true_for_compost():
	var ad := _make_action(ActionData.ActionType.COMPOST)
	assert_true(ad.need_card_selection)

func test_need_card_selection_false_for_water():
	var ad := _make_action(ActionData.ActionType.WATER)
	assert_false(ad.need_card_selection)

func test_need_card_selection_false_for_light():
	var ad := _make_action(ActionData.ActionType.LIGHT)
	assert_false(ad.need_card_selection)

# ----- get_calculated_value with NUMBER value_type -----

func test_calculated_value_number_type_returns_set_value():
	var ad := _make_action(ActionData.ActionType.WATER)
	ad.value_type = ActionData.ValueType.NUMBER
	ad.value = 5
	assert_eq(ad.get_calculated_value(null), 5)

func test_calculated_value_number_type_with_zero():
	var ad := _make_action(ActionData.ActionType.WATER)
	ad.value_type = ActionData.ValueType.NUMBER
	ad.value = 0
	assert_eq(ad.get_calculated_value(null), 0)

func test_calculated_value_adds_modified_value():
	var ad := _make_action(ActionData.ActionType.WATER)
	ad.value_type = ActionData.ValueType.NUMBER
	ad.value = 3
	ad.modified_value = 2
	assert_eq(ad.get_calculated_value(null), 5)

func test_calculated_value_modified_value_can_be_negative():
	var ad := _make_action(ActionData.ActionType.WATER)
	ad.value_type = ActionData.ValueType.NUMBER
	ad.value = 5
	ad.modified_value = -2
	assert_eq(ad.get_calculated_value(null), 3)

# ----- get_calculated_value with RANDOM value_type -----

func test_calculated_value_random_type_uses_original_value():
	# For RANDOM type, base_value is still _original_value (upper bound for display)
	var ad := _make_action(ActionData.ActionType.WATER)
	ad.value_type = ActionData.ValueType.RANDOM
	ad.value = 4
	# Result should be modified_value + original_value (no actual randomness in base calc)
	assert_eq(ad.get_calculated_value(null), 4)

# ----- get_calculated_x_value with NUMBER x_value_type -----

func test_calculated_x_value_number_type_returns_set_x_value():
	var ad := _make_action(ActionData.ActionType.UPDATE_X)
	ad.x_value_type = ActionData.XValueType.NUMBER
	ad.x_value = 7
	assert_eq(ad.get_calculated_x_value(null), 7)

func test_calculated_x_value_adds_modified_x_value():
	var ad := _make_action(ActionData.ActionType.UPDATE_X)
	ad.x_value_type = ActionData.XValueType.NUMBER
	ad.x_value = 3
	ad.modified_x_value = 4
	assert_eq(ad.get_calculated_x_value(null), 7)

func test_calculated_x_value_zero_when_no_combat_main_and_cards_in_hand_type():
	var ad := _make_action(ActionData.ActionType.UPDATE_X)
	ad.x_value_type = ActionData.XValueType.NUMBER_OF_TOOL_CARDS_IN_HAND
	# No combat_main set, so base_x_value = 0
	assert_eq(ad.get_calculated_x_value(null), 0)

func test_calculated_x_value_zero_when_no_target_plant_and_target_light_type():
	var ad := _make_action(ActionData.ActionType.UPDATE_X)
	ad.x_value_type = ActionData.XValueType.TARGET_LIGHT
	# No target_plant, so base_x_value = 0
	assert_eq(ad.get_calculated_x_value(null), 0)

# ----- get_calculated_value with X value_type delegates to get_calculated_x_value -----

func test_calculated_value_x_type_uses_x_value():
	var ad := _make_action(ActionData.ActionType.UPDATE_X)
	ad.value_type = ActionData.ValueType.X
	ad.x_value_type = ActionData.XValueType.NUMBER
	ad.x_value = 6
	assert_eq(ad.get_calculated_value(null), 6)

func test_calculated_value_x_type_adds_modified_value():
	var ad := _make_action(ActionData.ActionType.UPDATE_X)
	ad.value_type = ActionData.ValueType.X
	ad.x_value_type = ActionData.XValueType.NUMBER
	ad.x_value = 4
	ad.modified_value = 1
	assert_eq(ad.get_calculated_value(null), 5)

# ----- copy / get_duplicate -----

func test_duplicate_copies_type():
	var ad := _make_action(ActionData.ActionType.LIGHT)
	var dup := ad.get_duplicate()
	assert_eq(dup.type, ActionData.ActionType.LIGHT)

func test_duplicate_copies_value():
	var ad := _make_action(ActionData.ActionType.WATER)
	ad.value = 8
	var dup := ad.get_duplicate()
	assert_eq(dup.value, 8)

func test_duplicate_copies_value_type():
	var ad := _make_action(ActionData.ActionType.WATER)
	ad.value_type = ActionData.ValueType.RANDOM
	var dup := ad.get_duplicate()
	assert_eq(dup.value_type, ActionData.ValueType.RANDOM)

func test_duplicate_copies_operator_type():
	var ad := _make_action(ActionData.ActionType.WATER)
	ad.operator_type = ActionData.OperatorType.DECREASE
	var dup := ad.get_duplicate()
	assert_eq(dup.operator_type, ActionData.OperatorType.DECREASE)

func test_duplicate_copies_specials():
	var ad := _make_action(ActionData.ActionType.WATER)
	ad.specials = [ActionData.Special.ALL_FIELDS]
	var dup := ad.get_duplicate()
	assert_true(ActionData.Special.ALL_FIELDS in dup.specials)

func test_duplicate_specials_are_independent_copy():
	var ad := _make_action(ActionData.ActionType.WATER)
	ad.specials = [ActionData.Special.ALL_FIELDS]
	var dup := ad.get_duplicate()
	dup.specials.clear()
	assert_eq(ad.specials.size(), 1)

func test_duplicate_copies_modified_value():
	var ad := _make_action(ActionData.ActionType.WATER)
	ad.modified_value = 3
	var dup := ad.get_duplicate()
	assert_eq(dup.modified_value, 3)

func test_duplicate_copies_x_value():
	var ad := _make_action(ActionData.ActionType.UPDATE_X)
	ad.x_value = 5
	var dup := ad.get_duplicate()
	assert_eq(dup.x_value, 5)
