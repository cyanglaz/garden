extends GutTest

# Tests for PlantAbilityData – data class for plant abilities.

const FAKE_PATH := "res://fake/test_plant_ability.tres"

func _make_ability(id_val: String = "photosynthesis") -> PlantAbilityData:
	var ad := PlantAbilityData.new()
	ad.set("_original_resource_path", FAKE_PATH)
	ad.id = id_val
	ad.display_name = "Photosynthesis"
	ad.cooldown = 0
	return ad

# ----- get_ability_path -----

func test_get_ability_path_uses_id():
	var ad := _make_ability("photosynthesis")
	var path := ad.get_ability_path()
	assert_true(path.contains("photosynthesis"))

func test_get_ability_path_format():
	var ad := _make_ability("bloom")
	var path := ad.get_ability_path()
	assert_eq(path, "res://scenes/main_game/plants/abilities/plant_ability_bloom.tscn")

func test_get_ability_path_uses_full_id_with_upgrade():
	var ad := _make_ability("bloom+1")
	var path := ad.get_ability_path()
	assert_true(path.contains("bloom+1"))

# ----- copy / get_duplicate -----

func test_duplicate_copies_id():
	var ad := _make_ability("sleep")
	var dup := ad.get_duplicate()
	assert_eq(dup.id, "sleep")

func test_duplicate_copies_cooldown():
	var ad := _make_ability()
	ad.cooldown = 3
	var dup := ad.get_duplicate()
	assert_eq(dup.cooldown, 3)

func test_duplicate_cooldown_is_independent():
	var ad := _make_ability()
	ad.cooldown = 2
	var dup := ad.get_duplicate()
	dup.cooldown = 99
	assert_eq(ad.cooldown, 2)

func test_duplicate_copies_display_name():
	var ad := _make_ability()
	ad.display_name = "Sleep"
	var dup := ad.get_duplicate()
	assert_eq(dup.display_name, "Sleep")

func test_duplicate_zero_cooldown():
	var ad := _make_ability()
	ad.cooldown = 0
	var dup := ad.get_duplicate()
	assert_eq(dup.cooldown, 0)

# ----- level / base_id inherited from ThingData -----

func test_ability_level_zero_for_base_id():
	var ad := _make_ability("bloom")
	assert_eq(ad.level, 0)

func test_ability_level_from_upgraded_id():
	var ad := _make_ability("bloom+2")
	assert_eq(ad.level, 2)

func test_ability_base_id():
	var ad := _make_ability("bloom+1")
	assert_eq(ad.base_id, "bloom")
