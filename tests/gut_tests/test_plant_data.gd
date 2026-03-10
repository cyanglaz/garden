extends GutTest

# Tests for PlantData – plant configuration data class.

const FAKE_PATH := "res://fake/test_plant.tres"

func _make_plant(id_val: String = "rose") -> PlantData:
	var pd := PlantData.new()
	pd.set("_original_resource_path", FAKE_PATH)
	pd.id = id_val
	pd.display_name = "Rose"
	pd.light = 3
	pd.water = 2
	pd.difficulty = 1
	pd.chapters = [1, 2]
	pd.abilities = {}
	pd.initial_field_status = {}
	return pd

# ----- copy / get_duplicate -----

func test_duplicate_copies_id():
	var pd := _make_plant("tulip")
	var dup := pd.get_duplicate()
	assert_eq(dup.id, "tulip")

func test_duplicate_copies_light():
	var pd := _make_plant()
	pd.light = 5
	var dup := pd.get_duplicate()
	assert_eq(dup.light, 5)

func test_duplicate_copies_water():
	var pd := _make_plant()
	pd.water = 4
	var dup := pd.get_duplicate()
	assert_eq(dup.water, 4)

func test_duplicate_copies_difficulty():
	var pd := _make_plant()
	pd.difficulty = 2
	var dup := pd.get_duplicate()
	assert_eq(dup.difficulty, 2)

func test_duplicate_copies_chapters():
	var pd := _make_plant()
	pd.chapters = [1, 3, 5]
	var dup := pd.get_duplicate()
	assert_eq(dup.chapters.size(), 3)
	assert_true(1 in dup.chapters)
	assert_true(3 in dup.chapters)
	assert_true(5 in dup.chapters)

func test_duplicate_chapters_are_independent():
	var pd := _make_plant()
	pd.chapters = [1, 2, 3]
	var dup := pd.get_duplicate()
	dup.chapters.append(99)
	assert_eq(pd.chapters.size(), 3)

func test_duplicate_copies_abilities():
	var pd := _make_plant()
	pd.abilities = {"ability_1": true}
	var dup := pd.get_duplicate()
	assert_true(dup.abilities.has("ability_1"))

func test_duplicate_abilities_are_independent():
	var pd := _make_plant()
	pd.abilities = {"ability_1": true}
	var dup := pd.get_duplicate()
	dup.abilities["ability_2"] = true
	assert_false(pd.abilities.has("ability_2"))

func test_duplicate_copies_initial_field_status():
	var pd := _make_plant()
	pd.initial_field_status = {"drowned": 2}
	var dup := pd.get_duplicate()
	assert_true(dup.initial_field_status.has("drowned"))
	assert_eq(dup.initial_field_status["drowned"], 2)

func test_duplicate_initial_field_status_is_independent():
	var pd := _make_plant()
	pd.initial_field_status = {"drowned": 2}
	var dup := pd.get_duplicate()
	dup.initial_field_status["pest"] = 1
	assert_false(pd.initial_field_status.has("pest"))

func test_duplicate_display_name():
	var pd := _make_plant()
	pd.display_name = "Orchid"
	var dup := pd.get_duplicate()
	assert_eq(dup.display_name, "Orchid")

# ----- level / base_id (inherited from ThingData) -----

func test_plant_level_parsed_from_id():
	var pd := _make_plant("sunflower+2")
	assert_eq(pd.level, 2)

func test_plant_base_id_stripped():
	var pd := _make_plant("sunflower+2")
	assert_eq(pd.base_id, "sunflower")

# ----- get_display_name (inherited) -----

func test_get_display_name_no_postfix():
	var pd := _make_plant()
	pd.display_name = "Rose"
	pd.name_postfix = ""
	assert_eq(pd.get_display_name(), "Rose")

func test_get_display_name_with_postfix():
	var pd := _make_plant()
	pd.display_name = "Rose"
	pd.name_postfix = " +"
	assert_eq(pd.get_display_name(), "Rose +")
