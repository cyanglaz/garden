extends GutTest

# Tests for ActionData – the data model for individual card actions.

const FAKE_PATH := "res://fake/test_action.tres"

class FakeCombatMain extends CombatMain:
	var fake_plant: Plant = null
	func get_current_player_plant() -> Plant:
		return fake_plant

class FakeFieldStatusContainer extends FieldStatusContainer:
	var pest_stack_count: int = 0
	func get_status_stack(status_id: String) -> int:
		if status_id == "pest":
			return pest_stack_count
		return 0

class FakePlant extends Plant:
	pass

class FakePlayerStatusContainer extends PlayerStatusContainer:
	var fake_momentum_stack: int = 0
	func get_player_upgrade_stack(id: String) -> int:
		if id == "momentum":
			return fake_momentum_stack
		return 0

class FakePlayer extends Player:
	pass

func _make_combat_main_with_plant(plant: Plant) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.fake_plant = plant
	return cm

func _make_plant_with_pest_stack(pest_stack: int) -> FakePlant:
	var p := FakePlant.new()
	autofree(p)
	var fsc := FakeFieldStatusContainer.new()
	autofree(fsc)
	fsc.pest_stack_count = pest_stack
	p.field_status_container = fsc
	return p

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

func test_calculated_x_value_zero_when_no_target_plant_and_target_pest_type():
	var ad := _make_action(ActionData.ActionType.UPDATE_X)
	ad.x_value_type = ActionData.XValueType.TARGET_PEST
	assert_eq(ad.get_calculated_x_value(null), 0)

func test_calculated_x_value_zero_when_combat_main_has_no_plant_and_target_pest_type():
	var ad := _make_action(ActionData.ActionType.UPDATE_X)
	ad.x_value_type = ActionData.XValueType.TARGET_PEST
	var cm := _make_combat_main_with_plant(null)
	assert_eq(ad.get_calculated_x_value(cm), 0)

func test_calculated_x_value_target_pest_matches_plant_pest_stack():
	var plant := _make_plant_with_pest_stack(4)
	var cm := _make_combat_main_with_plant(plant)
	var ad := _make_action(ActionData.ActionType.UPDATE_X)
	ad.x_value_type = ActionData.XValueType.TARGET_PEST
	assert_eq(ad.get_calculated_x_value(cm), 4)

func test_calculated_x_value_target_pest_adds_modified_x_value():
	var plant := _make_plant_with_pest_stack(3)
	var cm := _make_combat_main_with_plant(plant)
	var ad := _make_action(ActionData.ActionType.UPDATE_X)
	ad.x_value_type = ActionData.XValueType.TARGET_PEST
	ad.modified_x_value = 2
	assert_eq(ad.get_calculated_x_value(cm), 5)

# ----- get_calculated_x_value with PLAYER_ENERGY x_value_type -----

func _make_combat_main_with_energy(energy: int) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	autofree(cm)
	var rp := ResourcePoint.new()
	autofree(rp)
	rp.setup(energy, 10)
	cm.energy_tracker = rp
	return cm

func test_calculated_x_value_player_energy_returns_zero_when_no_combat_main():
	var ad := _make_action(ActionData.ActionType.ENERGY)
	ad.x_value_type = ActionData.XValueType.PLAYER_ENERGY
	assert_eq(ad.get_calculated_x_value(null), 0)

func test_calculated_x_value_player_energy_reads_energy_tracker_value():
	var cm := _make_combat_main_with_energy(5)
	var ad := _make_action(ActionData.ActionType.ENERGY)
	ad.x_value_type = ActionData.XValueType.PLAYER_ENERGY
	assert_eq(ad.get_calculated_x_value(cm), 5)

func test_calculated_x_value_player_energy_zero_when_energy_is_zero():
	var cm := _make_combat_main_with_energy(0)
	var ad := _make_action(ActionData.ActionType.ENERGY)
	ad.x_value_type = ActionData.XValueType.PLAYER_ENERGY
	assert_eq(ad.get_calculated_x_value(cm), 0)

func test_calculated_x_value_player_energy_adds_modified_x_value():
	var cm := _make_combat_main_with_energy(3)
	var ad := _make_action(ActionData.ActionType.ENERGY)
	ad.x_value_type = ActionData.XValueType.PLAYER_ENERGY
	ad.modified_x_value = 2
	assert_eq(ad.get_calculated_x_value(cm), 5)

func test_calculated_value_x_type_with_player_energy_x_value_type():
	var cm := _make_combat_main_with_energy(4)
	var ad := _make_action(ActionData.ActionType.LIGHT)
	ad.value_type = ActionData.ValueType.X
	ad.x_value_type = ActionData.XValueType.PLAYER_ENERGY
	assert_eq(ad.get_calculated_value(cm), 4)

# ----- get_calculated_x_value with PLAYER_MOMENTUM x_value_type -----

func _make_combat_main_with_momentum(momentum: int) -> FakeCombatMain:
	var container := FakePlayerStatusContainer.new()
	autofree(container)
	container.fake_momentum_stack = momentum
	var fake_player := FakePlayer.new()
	autofree(fake_player)
	fake_player.player_status_container = container
	var cm := FakeCombatMain.new()
	autofree(cm)
	cm.player = fake_player
	return cm

func test_calculated_x_value_player_momentum_returns_zero_when_no_combat_main():
	var ad := _make_action(ActionData.ActionType.MOMENTUM)
	ad.x_value_type = ActionData.XValueType.PLAYER_MOMENTUM
	assert_eq(ad.get_calculated_x_value(null), 0)

func test_calculated_x_value_player_momentum_reads_momentum_stack():
	var cm := _make_combat_main_with_momentum(4)
	var ad := _make_action(ActionData.ActionType.MOMENTUM)
	ad.x_value_type = ActionData.XValueType.PLAYER_MOMENTUM
	assert_eq(ad.get_calculated_x_value(cm), 4)

func test_calculated_x_value_player_momentum_zero_when_momentum_is_zero():
	var cm := _make_combat_main_with_momentum(0)
	var ad := _make_action(ActionData.ActionType.MOMENTUM)
	ad.x_value_type = ActionData.XValueType.PLAYER_MOMENTUM
	assert_eq(ad.get_calculated_x_value(cm), 0)

func test_calculated_x_value_player_momentum_adds_modified_x_value():
	var cm := _make_combat_main_with_momentum(3)
	var ad := _make_action(ActionData.ActionType.MOMENTUM)
	ad.x_value_type = ActionData.XValueType.PLAYER_MOMENTUM
	ad.modified_x_value = 2
	assert_eq(ad.get_calculated_x_value(cm), 5)

func test_calculated_value_x_type_with_player_momentum_x_value_type():
	var cm := _make_combat_main_with_momentum(6)
	var ad := _make_action(ActionData.ActionType.LIGHT)
	ad.value_type = ActionData.ValueType.X
	ad.x_value_type = ActionData.XValueType.PLAYER_MOMENTUM
	assert_eq(ad.get_calculated_value(cm), 6)

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
