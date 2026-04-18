extends GutTest

# Tests for ToolData – the data model for player cards / tools.

const FAKE_PATH := "res://fake/test_tool.tres"

func _make_tool(rarity_val: int = 0) -> ToolData:
	var td := ToolData.new()
	td.set("_original_resource_path", FAKE_PATH)
	td.id = "test_fixture"
	td.rarity = rarity_val
	td.energy_cost = 1
	td.turn_energy_modifier = 0
	td.level_energy_modifier = 0
	return td

func _make_action(action_type: ActionData.ActionType, value: int = 1) -> ActionData:
	var ad := ActionData.new()
	ad.set("_original_resource_path", FAKE_PATH)
	ad.type = action_type
	ad.value = value
	ad.value_type = ActionData.ValueType.NUMBER
	return ad

# ----- get_final_energy_cost -----

func test_final_energy_cost_no_modifiers():
	var td := _make_tool()
	td.energy_cost = 2
	assert_eq(td.get_final_energy_cost(), 2)

func test_final_energy_cost_with_turn_modifier():
	var td := _make_tool()
	td.energy_cost = 2
	td.turn_energy_modifier = -1
	assert_eq(td.get_final_energy_cost(), 1)

func test_final_energy_cost_with_level_modifier():
	var td := _make_tool()
	td.energy_cost = 3
	td.level_energy_modifier = 1
	assert_eq(td.get_final_energy_cost(), 4)

func test_final_energy_cost_with_both_modifiers():
	var td := _make_tool()
	td.energy_cost = 5
	td.turn_energy_modifier = -2
	td.level_energy_modifier = 1
	assert_eq(td.get_final_energy_cost(), 4)

func test_final_energy_cost_can_be_zero():
	var td := _make_tool()
	td.energy_cost = 2
	td.turn_energy_modifier = -2
	assert_eq(td.get_final_energy_cost(), 0)

# ----- get_total_energy_modifier -----

func test_total_energy_modifier_zero_by_default():
	var td := _make_tool()
	assert_eq(td.get_total_energy_modifier(), 0)

func test_total_energy_modifier_sums_both_modifiers():
	var td := _make_tool()
	td.turn_energy_modifier = 3
	td.level_energy_modifier = 2
	assert_eq(td.get_total_energy_modifier(), 5)

func test_total_energy_modifier_with_negative_turn():
	var td := _make_tool()
	td.turn_energy_modifier = -2
	td.level_energy_modifier = 0
	assert_eq(td.get_total_energy_modifier(), -2)

# ----- refresh_for_turn -----

func test_refresh_for_turn_resets_turn_energy_modifier():
	var td := _make_tool()
	td.turn_energy_modifier = -3
	td.refresh_for_turn()
	assert_eq(td.turn_energy_modifier, 0)

func test_refresh_for_turn_does_not_touch_level_modifier():
	var td := _make_tool()
	td.turn_energy_modifier = -3
	td.level_energy_modifier = 2
	td.refresh_for_turn()
	assert_eq(td.level_energy_modifier, 2)

# ----- refresh_for_level -----

func test_refresh_for_level_resets_level_energy_modifier():
	var td := _make_tool()
	td.level_energy_modifier = 5
	td.refresh_for_level()
	assert_eq(td.level_energy_modifier, 0)

func test_refresh_for_level_resets_action_modified_values():
	var td := _make_tool()
	var action := _make_action(ActionData.ActionType.WATER, 3)
	action.modified_value = 4
	action.modified_x_value = 2
	td.actions = [action]
	td.refresh_for_level()
	assert_eq(action.modified_value, 0)
	assert_eq(action.modified_x_value, 0)

func test_refresh_for_level_resets_all_actions():
	var td := _make_tool()
	var a1 := _make_action(ActionData.ActionType.WATER, 2)
	var a2 := _make_action(ActionData.ActionType.LIGHT, 3)
	a1.modified_value = 1
	a2.modified_value = 5
	td.actions = [a1, a2]
	td.refresh_for_level()
	assert_eq(a1.modified_value, 0)
	assert_eq(a2.modified_value, 0)

# ----- _get_cost (rarity-based shop cost) -----

func test_cost_for_common():
	var td := _make_tool(0)
	assert_eq(td.cost, 6)

func test_cost_for_uncommon():
	var td := _make_tool(1)
	assert_eq(td.cost, 11)

func test_cost_for_rare():
	var td := _make_tool(2)
	assert_eq(td.cost, 19)

func test_cost_for_temp_card():
	var td := _make_tool(-1)
	assert_eq(td.cost, 0)

# ----- reverse -----

func test_reverse_swaps_push_left_to_push_right():
	var td := _make_tool()
	td.specials = [ToolData.Special.REVERSIBLE]
	var action := _make_action(ActionData.ActionType.PUSH_LEFT)
	td.actions = [action]
	td.reverse(null)
	assert_eq(action.type, ActionData.ActionType.PUSH_RIGHT)

func test_reverse_swaps_push_right_to_push_left():
	var td := _make_tool()
	td.specials = [ToolData.Special.REVERSIBLE]
	var action := _make_action(ActionData.ActionType.PUSH_RIGHT)
	td.actions = [action]
	td.reverse(null)
	assert_eq(action.type, ActionData.ActionType.PUSH_LEFT)

func test_reverse_double_reverse_restores_original():
	var td := _make_tool()
	td.specials = [ToolData.Special.REVERSIBLE]
	var action := _make_action(ActionData.ActionType.PUSH_LEFT)
	td.actions = [action]
	td.reverse(null)
	td.reverse(null)
	assert_eq(action.type, ActionData.ActionType.PUSH_LEFT)

func test_reverse_does_not_affect_non_push_actions():
	var td := _make_tool()
	td.specials = [ToolData.Special.REVERSIBLE]
	var push_action := _make_action(ActionData.ActionType.PUSH_LEFT)
	var water_action := _make_action(ActionData.ActionType.WATER)
	td.actions = [push_action, water_action]
	td.reverse(null)
	assert_eq(water_action.type, ActionData.ActionType.WATER)

# ----- _get_has_tooltip -----

func test_has_tooltip_true_when_actions_exist():
	var td := _make_tool()
	td.actions = [_make_action(ActionData.ActionType.WATER)]
	td.specials = []
	assert_true(td.has_tooltip)

func test_has_tooltip_true_when_specials_exist():
	var td := _make_tool()
	td.actions = []
	td.specials = [ToolData.Special.COMPOST]
	assert_true(td.has_tooltip)

func test_has_tooltip_false_when_both_empty():
	var td := _make_tool()
	td.actions = []
	td.specials = []
	assert_false(td.has_tooltip)

# ----- get_duplicate -----

func test_duplicate_copies_energy_cost():
	var td := _make_tool()
	td.energy_cost = 4
	var dup := td.get_duplicate()
	assert_eq(dup.energy_cost, 4)

func test_duplicate_copies_rarity():
	var td := _make_tool(2)
	var dup := td.get_duplicate()
	assert_eq(dup.rarity, 2)

func test_duplicate_copies_specials():
	var td := _make_tool()
	td.specials = [ToolData.Special.COMPOST, ToolData.Special.HANDY]
	var dup := td.get_duplicate()
	assert_true(ToolData.Special.COMPOST in dup.specials)
	assert_true(ToolData.Special.HANDY in dup.specials)

func test_duplicate_specials_are_independent():
	var td := _make_tool()
	td.specials = [ToolData.Special.COMPOST]
	var dup := td.get_duplicate()
	dup.specials.clear()
	assert_eq(td.specials.size(), 1)

func test_duplicate_copies_actions():
	var td := _make_tool()
	var action := _make_action(ActionData.ActionType.WATER, 5)
	td.actions = [action]
	var dup := td.get_duplicate()
	assert_eq(dup.actions.size(), 1)
	assert_eq(dup.actions[0].type, ActionData.ActionType.WATER)

func test_duplicate_actions_are_independent():
	var td := _make_tool()
	var action := _make_action(ActionData.ActionType.WATER, 5)
	td.actions = [action]
	var dup := td.get_duplicate()
	dup.actions[0].modified_value = 99
	assert_eq(action.modified_value, 0)

func test_duplicate_type_is_copied():
	var td := _make_tool()
	td.type = ToolData.Type.POWER
	var dup := td.get_duplicate()
	assert_eq(dup.type, ToolData.Type.POWER)

# ----- enchant_data -----

func _make_enchant(rarity_val: int = 0, action_type: ActionData.ActionType = ActionData.ActionType.WATER, action_value: int = 2) -> EnchantData:
	var ed := EnchantData.new()
	ed.set("_original_resource_path", FAKE_PATH)
	ed.id = "test_enchant"
	ed.rarity = rarity_val
	var ad := _make_action(action_type, action_value)
	ed.action_data = ad
	return ed

func test_duplicate_with_null_enchant_data_stays_null():
	var td := _make_tool()
	td.enchant_data = null
	var dup := td.get_duplicate()
	assert_null(dup.enchant_data)

func test_duplicate_copies_enchant_data():
	var td := _make_tool()
	td.enchant_data = _make_enchant(1, ActionData.ActionType.LIGHT, 3)
	var dup := td.get_duplicate()
	assert_not_null(dup.enchant_data)
	assert_eq(dup.enchant_data.rarity, 1)
	assert_eq(dup.enchant_data.action_data.type, ActionData.ActionType.LIGHT)

func test_duplicate_enchant_data_is_separate_instance():
	var td := _make_tool()
	td.enchant_data = _make_enchant()
	var dup := td.get_duplicate()
	assert_ne(dup.enchant_data, td.enchant_data)

func test_duplicate_enchant_data_is_independent():
	var td := _make_tool()
	td.enchant_data = _make_enchant(1, ActionData.ActionType.WATER, 2)
	var dup := td.get_duplicate()
	dup.enchant_data.rarity = 2
	dup.enchant_data.action_data.modified_value = 42
	assert_eq(td.enchant_data.rarity, 1)
	assert_eq(td.enchant_data.action_data.modified_value, 0)
