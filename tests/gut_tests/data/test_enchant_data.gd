extends GutTest

# Tests for EnchantData – the data model for tool enchantments.

const FAKE_PATH := "res://fake/test_enchant.tres"

func _make_action(action_type: ActionData.ActionType = ActionData.ActionType.WATER, value: int = 2) -> ActionData:
	var ad := ActionData.new()
	ad.set("_original_resource_path", FAKE_PATH)
	ad.type = action_type
	ad.value = value
	ad.value_type = ActionData.ValueType.NUMBER
	return ad

func _make_enchant(id_val: String = "water", rarity_val: int = 0) -> EnchantData:
	var ed := EnchantData.new()
	ed.set("_original_resource_path", FAKE_PATH)
	ed.id = id_val
	ed.rarity = rarity_val
	ed.action_data = _make_action()
	return ed

# ----- copy / get_duplicate -----

func test_duplicate_copies_id():
	var ed := _make_enchant("light", 1)
	var dup := ed.get_duplicate()
	assert_eq(dup.id, "light")

func test_duplicate_copies_rarity():
	var ed := _make_enchant("light", 2)
	var dup := ed.get_duplicate()
	assert_eq(dup.rarity, 2)

func test_duplicate_with_default_rarity():
	var ed := _make_enchant("water", 0)
	var dup := ed.get_duplicate()
	assert_eq(dup.rarity, 0)

func test_duplicate_returns_new_instance():
	var ed := _make_enchant()
	var dup := ed.get_duplicate()
	assert_ne(dup, ed)

func test_duplicate_returns_enchant_data_instance():
	var ed := _make_enchant()
	var dup := ed.get_duplicate()
	assert_true(dup is EnchantData)

func test_duplicate_copies_action_data():
	var ed := _make_enchant()
	ed.action_data = _make_action(ActionData.ActionType.LIGHT, 4)
	var dup := ed.get_duplicate()
	assert_eq(dup.action_data.type, ActionData.ActionType.LIGHT)
	assert_eq(dup.action_data.value, 4)

func test_duplicate_action_data_is_separate_instance():
	var ed := _make_enchant()
	var dup := ed.get_duplicate()
	assert_ne(dup.action_data, ed.action_data)

func test_duplicate_action_data_is_independent():
	var ed := _make_enchant()
	ed.action_data = _make_action(ActionData.ActionType.WATER, 3)
	var dup := ed.get_duplicate()
	dup.action_data.modified_value = 99
	assert_eq(ed.action_data.modified_value, 0)

func test_duplicate_rarity_is_independent():
	var ed := _make_enchant("water", 1)
	var dup := ed.get_duplicate()
	dup.rarity = 2
	assert_eq(ed.rarity, 1)

# ----- _get_localization_prefix -----

func test_localization_prefix():
	var ed := _make_enchant()
	assert_eq(ed._get_localization_prefix(), "ENCHANT_")
