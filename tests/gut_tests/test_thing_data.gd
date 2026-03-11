extends GutTest

# Tests for ThingData – the base data class for all game resources.
# Note: ThingData.copy() requires either a non-empty resource_path or
#       _original_resource_path on the source object.  We set
#       _original_resource_path manually on freshly constructed instances.

const FAKE_PATH := "res://fake/test_resource.tres"

func _make_thing(id_val: String = "flower") -> ThingData:
	var td := ThingData.new()
	td.id = id_val
	td.display_name = "Flower"
	td.description = "A lovely flower."
	td.data = {}
	# Required by copy() when resource_path is empty (freshly constructed).
	td.set("_original_resource_path", FAKE_PATH)
	return td

# ----- _get_level -----

func test_level_returns_zero_for_base_id():
	var td := _make_thing("flower")
	assert_eq(td.level, 0)

func test_level_returns_correct_level_for_upgraded_id():
	var td := _make_thing("flower+2")
	assert_eq(td.level, 2)

func test_level_returns_one_for_first_upgrade():
	var td := _make_thing("flower+1")
	assert_eq(td.level, 1)

func test_level_returns_high_number():
	var td := _make_thing("flower+10")
	assert_eq(td.level, 10)

# ----- _get_base_id -----

func test_base_id_returns_full_id_when_no_plus():
	var td := _make_thing("tulip")
	assert_eq(td.base_id, "tulip")

func test_base_id_strips_plus_suffix():
	var td := _make_thing("tulip+3")
	assert_eq(td.base_id, "tulip")

func test_base_id_with_underscore_in_name():
	var td := _make_thing("magic_flower+1")
	assert_eq(td.base_id, "magic_flower")

# ----- _get_upgrade_to_id -----

func test_upgrade_to_id_from_base():
	var td := _make_thing("rose")
	assert_eq(td.upgrade_to_id, "rose+1")

func test_upgrade_to_id_from_level_one():
	var td := _make_thing("rose+1")
	assert_eq(td.upgrade_to_id, "rose+2")

func test_upgrade_to_id_from_level_two():
	var td := _make_thing("rose+2")
	assert_eq(td.upgrade_to_id, "rose+3")

# ----- _get_upgraded_from_id -----

func test_upgraded_from_id_at_level_zero_is_empty():
	var td := _make_thing("daisy")
	assert_eq(td.upgraded_from_id, "")

func test_upgraded_from_id_at_level_one_is_base():
	var td := _make_thing("daisy+1")
	assert_eq(td.upgraded_from_id, "daisy")

func test_upgraded_from_id_at_level_two():
	var td := _make_thing("daisy+2")
	assert_eq(td.upgraded_from_id, "daisy+1")

func test_upgraded_from_id_at_level_three():
	var td := _make_thing("daisy+3")
	assert_eq(td.upgraded_from_id, "daisy+2")

# ----- get_display_name -----

func test_display_name_without_postfix():
	var td := _make_thing("sunflower")
	td.display_name = "Sunflower"
	td.name_postfix = ""
	assert_eq(td.get_display_name(), "Sunflower")

func test_display_name_with_postfix():
	var td := _make_thing("sunflower")
	td.display_name = "Sunflower"
	td.name_postfix = " +"
	assert_eq(td.get_display_name(), "Sunflower +")

func test_display_name_with_empty_postfix():
	var td := _make_thing("sunflower")
	td.display_name = "Sunflower"
	td.name_postfix = ""
	assert_eq(td.get_display_name(), "Sunflower")

# ----- copy / get_duplicate -----

func test_get_duplicate_copies_id():
	var td := _make_thing("orchid")
	var dup := td.get_duplicate()
	assert_eq(dup.id, "orchid")

func test_get_duplicate_copies_display_name():
	var td := _make_thing("orchid")
	td.display_name = "Orchid"
	var dup := td.get_duplicate()
	assert_eq(dup.display_name, "Orchid")

func test_get_duplicate_copies_data_dictionary():
	var td := _make_thing("orchid")
	td.data = {"key": "value", "num": 42}
	var dup := td.get_duplicate()
	assert_eq(dup.data["key"], "value")
	assert_eq(dup.data["num"], 42)

func test_get_duplicate_data_is_independent_copy():
	var td := _make_thing("orchid")
	td.data = {"key": "original"}
	var dup := td.get_duplicate()
	dup.data["key"] = "modified"
	assert_eq(td.data["key"], "original")
