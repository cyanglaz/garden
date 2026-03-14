extends GutTest

# Tests for EventData and EventOptionData – narrative event configuration.

const FAKE_PATH := "res://fake/test_event.tres"

func _make_event(id_val: String = "forest_encounter") -> EventData:
	var ed := EventData.new()
	ed.set("_original_resource_path", FAKE_PATH)
	ed.id = id_val
	ed.chapters = [1, 2]
	ed.option_ids = ["help", "flee"]
	return ed

func _make_event_option(id_val: String = "help_option") -> EventOptionData:
	var eod := EventOptionData.new()
	eod.set("_original_resource_path", FAKE_PATH)
	eod.id = id_val
	eod.positive_description = "You gain gold."
	eod.negative_description = "You lose HP."
	eod.script_id = "event_option_help"
	return eod

# ----- EventData: copy / get_duplicate -----

func test_event_duplicate_copies_id():
	var ed := _make_event("cave_trap")
	var dup := ed.get_duplicate()
	assert_eq(dup.id, "cave_trap")


func test_event_duplicate_copies_chapters():
	var ed := _make_event()
	ed.chapters = [2, 4]
	var dup := ed.get_duplicate()
	assert_eq(dup.chapters.size(), 2)
	assert_true(2 in dup.chapters)
	assert_true(4 in dup.chapters)

func test_event_chapters_are_independent():
	var ed := _make_event()
	ed.chapters = [1, 2]
	var dup := ed.get_duplicate()
	dup.chapters.append(99)
	assert_eq(ed.chapters.size(), 2)

func test_event_duplicate_copies_option_ids():
	var ed := _make_event()
	ed.option_ids = ["attack", "flee", "negotiate"]
	var dup := ed.get_duplicate()
	assert_eq(dup.option_ids.size(), 3)
	assert_true("attack" in dup.option_ids)
	assert_true("flee" in dup.option_ids)
	assert_true("negotiate" in dup.option_ids)

func test_event_option_ids_are_independent():
	var ed := _make_event()
	ed.option_ids = ["flee"]
	var dup := ed.get_duplicate()
	dup.option_ids.append("attack")
	assert_eq(ed.option_ids.size(), 1)

func test_event_duplicate_empty_chapters():
	var ed := _make_event()
	ed.chapters = []
	var dup := ed.get_duplicate()
	assert_eq(dup.chapters.size(), 0)

func test_event_duplicate_empty_option_ids():
	var ed := _make_event()
	ed.option_ids = []
	var dup := ed.get_duplicate()
	assert_eq(dup.option_ids.size(), 0)

# ----- EventOptionData: copy / get_duplicate -----

func test_option_duplicate_copies_id():
	var eod := _make_event_option("attack_option")
	var dup := eod.get_duplicate()
	assert_eq(dup.id, "attack_option")

func test_option_duplicate_copies_positive_description():
	var eod := _make_event_option()
	eod.positive_description = "You gain 10 gold."
	var dup := eod.get_duplicate()
	assert_eq(dup.positive_description, "You gain 10 gold.")

func test_option_duplicate_copies_negative_description():
	var eod := _make_event_option()
	eod.negative_description = "You lose 5 HP."
	var dup := eod.get_duplicate()
	assert_eq(dup.negative_description, "You lose 5 HP.")


func test_option_duplicate_empty_descriptions():
	var eod := _make_event_option()
	eod.positive_description = ""
	eod.negative_description = ""
	var dup := eod.get_duplicate()
	assert_eq(dup.positive_description, "")
	assert_eq(dup.negative_description, "")

func test_option_positive_description_independent():
	var eod := _make_event_option()
	eod.positive_description = "You gain gold."
	var dup := eod.get_duplicate()
	dup.positive_description = "Modified"
	assert_eq(eod.positive_description, "You gain gold.")

func test_option_negative_description_independent():
	var eod := _make_event_option()
	eod.negative_description = "You lose HP."
	var dup := eod.get_duplicate()
	dup.negative_description = "Modified"
	assert_eq(eod.negative_description, "You lose HP.")
