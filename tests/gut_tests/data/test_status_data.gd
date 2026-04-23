extends GutTest

# Tests for StatusData – field status effect configuration.
# Also covers TrinketData and PowerData as related stack-based data classes.

const FAKE_PATH := "res://fake/test_status.tres"

func _make_status(type: StatusData.Type = StatusData.Type.BAD) -> StatusData:
	var sd := StatusData.new()
	sd.set("_original_resource_path", FAKE_PATH)
	sd.id = "drowned"
	sd.type = type
	sd.popup_message = "Drowned!"
	sd.stackable = true
	sd.single_turn = false
	sd.reduce_stack_on_turn_end = true
	sd.reduce_stack_on_trigger = false
	sd.remove_on_trigger = false
	return sd

func _make_trinket(rarity: int = 0) -> TrinketData:
	var td := TrinketData.new()
	td.set("_original_resource_path", FAKE_PATH)
	td.id = "lucky_charm"
	td.rarity = rarity
	return td

# ----- StatusData: stack setter syncs data dict -----

func test_stack_setter_updates_stack_property():
	var sd := _make_status()
	sd.stack = 3
	assert_eq(sd.stack, 3)

func test_stack_setter_syncs_data_dict():
	var sd := _make_status()
	sd.stack = 5
	assert_eq(sd.data["stack"], "5")

func test_stack_setter_with_zero():
	var sd := _make_status()
	sd.stack = 0
	assert_eq(sd.stack, 0)
	assert_eq(sd.data["stack"], "0")

func test_stack_setter_updates_after_multiple_assignments():
	var sd := _make_status()
	sd.stack = 2
	sd.stack = 7
	assert_eq(sd.stack, 7)
	assert_eq(sd.data["stack"], "7")

# ----- StatusData: copy / get_duplicate -----

func test_status_duplicate_copies_type_bad():
	var sd := _make_status(StatusData.Type.BAD)
	var dup := sd.get_duplicate()
	assert_eq(dup.type, StatusData.Type.BAD)

func test_status_duplicate_copies_type_good():
	var sd := _make_status(StatusData.Type.GOOD)
	var dup := sd.get_duplicate()
	assert_eq(dup.type, StatusData.Type.GOOD)

func test_status_duplicate_copies_popup_message():
	var sd := _make_status()
	sd.popup_message = "Fungus applied!"
	var dup := sd.get_duplicate()
	assert_eq(dup.popup_message, "Fungus applied!")

func test_status_duplicate_copies_stackable_true():
	var sd := _make_status()
	sd.stackable = true
	var dup := sd.get_duplicate()
	assert_true(dup.stackable)

func test_status_duplicate_copies_stackable_false():
	var sd := _make_status()
	sd.stackable = false
	var dup := sd.get_duplicate()
	assert_false(dup.stackable)

func test_status_duplicate_copies_single_turn():
	var sd := _make_status()
	sd.single_turn = true
	var dup := sd.get_duplicate()
	assert_true(dup.single_turn)

func test_status_duplicate_copies_reduce_stack_on_turn_end():
	var sd := _make_status()
	sd.reduce_stack_on_turn_end = true
	var dup := sd.get_duplicate()
	assert_true(dup.reduce_stack_on_turn_end)

func test_status_duplicate_copies_reduce_stack_on_trigger():
	var sd := _make_status()
	sd.reduce_stack_on_trigger = true
	var dup := sd.get_duplicate()
	assert_true(dup.reduce_stack_on_trigger)

func test_status_duplicate_copies_remove_on_trigger():
	var sd := _make_status()
	sd.remove_on_trigger = true
	var dup := sd.get_duplicate()
	assert_true(dup.remove_on_trigger)

func test_status_duplicate_copies_stack():
	var sd := _make_status()
	sd.stack = 4
	var dup := sd.get_duplicate()
	assert_eq(dup.stack, 4)

func test_status_duplicate_stack_syncs_data_dict():
	var sd := _make_status()
	sd.stack = 6
	var dup := sd.get_duplicate()
	assert_eq(dup.data["stack"], "6")

func test_status_type_enum_has_two_values():
	assert_eq(StatusData.Type.values().size(), 2)

# ----- TrinketData: stack setter syncs data dict -----

func test_trinket_stack_setter_updates_property():
	var td := _make_trinket()
	td.stack = 2
	assert_eq(td.stack, 2)

func test_trinket_stack_setter_syncs_data_dict():
	var td := _make_trinket()
	td.stack = 3
	assert_eq(td.data["stack"], "3")

func test_trinket_stack_zero():
	var td := _make_trinket()
	td.stack = 0
	assert_eq(td.data["stack"], "0")

func test_trinket_stack_multiple_updates():
	var td := _make_trinket()
	td.stack = 1
	td.stack = 4
	assert_eq(td.data["stack"], "4")

# ----- TrinketData: copy / get_duplicate -----

func test_trinket_duplicate_copies_id():
	var td := _make_trinket()
	td.id = "ring_of_growth"
	var dup := td.get_duplicate()
	assert_eq(dup.id, "ring_of_growth")

func test_trinket_duplicate_copies_rarity():
	var td := _make_trinket(2)
	var dup := td.get_duplicate()
	assert_eq(dup.rarity, 2)

func test_trinket_duplicate_copies_stack():
	var td := _make_trinket()
	td.stack = 5
	var dup := td.get_duplicate()
	assert_eq(dup.stack, 5)

func test_trinket_duplicate_rarity_common():
	var td := _make_trinket(0)
	var dup := td.get_duplicate()
	assert_eq(dup.rarity, 0)

func test_trinket_duplicate_rarity_uncommon():
	var td := _make_trinket(1)
	var dup := td.get_duplicate()
	assert_eq(dup.rarity, 1)

func test_trinket_rarity_independent():
	var td := _make_trinket(1)
	var dup := td.get_duplicate()
	dup.rarity = 2
	assert_eq(td.rarity, 1)
