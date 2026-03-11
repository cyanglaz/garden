extends GutTest

# Tests for WeatherData and WeatherAbilityData.

const FAKE_PATH := "res://fake/test_weather.tres"

func _make_weather(id_val: String = "sunny") -> WeatherData:
	var wd := WeatherData.new()
	wd.set("_original_resource_path", FAKE_PATH)
	wd.id = id_val
	wd.display_name = "Sunny"
	wd.sky_color = Color.WHITE
	wd.boss = false
	return wd

func _make_weather_ability(id_val: String = "rain_shower") -> WeatherAbilityData:
	var wa := WeatherAbilityData.new()
	wa.set("_original_resource_path", FAKE_PATH)
	wa.id = id_val
	wa.display_name = "Rain Shower"
	wa.action_datas = []
	return wa

func _make_action() -> ActionData:
	var ad := ActionData.new()
	ad.set("_original_resource_path", FAKE_PATH)
	ad.type = ActionData.ActionType.WATER
	ad.value = 2
	return ad

# ----- WeatherData: copy / get_duplicate -----

func test_weather_duplicate_copies_id():
	var wd := _make_weather("rainy")
	var dup := wd.get_duplicate()
	assert_eq(dup.id, "rainy")

func test_weather_duplicate_copies_sky_color():
	var wd := _make_weather()
	wd.sky_color = Color.BLUE
	var dup := wd.get_duplicate()
	assert_eq(dup.sky_color, Color.BLUE)

func test_weather_duplicate_copies_boss_false():
	var wd := _make_weather()
	wd.boss = false
	var dup := wd.get_duplicate()
	assert_false(dup.boss)

func test_weather_duplicate_copies_boss_true():
	var wd := _make_weather()
	wd.boss = true
	var dup := wd.get_duplicate()
	assert_true(dup.boss)

func test_weather_duplicate_copies_display_name():
	var wd := _make_weather()
	wd.display_name = "Blizzard"
	var dup := wd.get_duplicate()
	assert_eq(dup.display_name, "Blizzard")

func test_weather_boss_flag_independent():
	var wd := _make_weather()
	wd.boss = true
	var dup := wd.get_duplicate()
	dup.boss = false
	assert_true(wd.boss)

# ----- WeatherAbilityData: copy / get_duplicate -----

func test_weather_ability_duplicate_copies_id():
	var wa := _make_weather_ability("thunder")
	var dup := wa.get_duplicate()
	assert_eq(dup.id, "thunder")

func test_weather_ability_duplicate_copies_action_datas_count():
	var wa := _make_weather_ability()
	wa.action_datas = [_make_action(), _make_action()]
	var dup := wa.get_duplicate()
	assert_eq(dup.action_datas.size(), 2)

func test_weather_ability_duplicate_action_datas_empty():
	var wa := _make_weather_ability()
	wa.action_datas = []
	var dup := wa.get_duplicate()
	assert_eq(dup.action_datas.size(), 0)

func test_weather_ability_action_datas_are_independent():
	var wa := _make_weather_ability()
	wa.action_datas = [_make_action()]
	var dup := wa.get_duplicate()
	# action_datas.duplicate() is shallow – the array itself is independent
	dup.action_datas.append(_make_action())
	assert_eq(wa.action_datas.size(), 1)

func test_weather_ability_duplicate_copies_display_name():
	var wa := _make_weather_ability()
	wa.display_name = "Thunder Strike"
	var dup := wa.get_duplicate()
	assert_eq(dup.display_name, "Thunder Strike")
