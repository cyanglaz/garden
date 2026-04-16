extends GutTest


class FakeWeatherDatabase extends WeatherDatabase:
	var weathers: Array[WeatherData] = []

	func get_weathers_by_chapter(_chapter: int) -> Array[WeatherData]:
		var result: Array[WeatherData] = []
		for weather_data in weathers:
			result.append(weather_data.get_duplicate())
		return result


func _make_weather(id_value: String, boss: bool) -> WeatherData:
	var weather := WeatherData.new()
	weather.id = id_value
	weather.boss = boss
	weather.sky_color = Color.WHITE
	return weather


func test_start_uses_test_weather_duplicate() -> void:
	var manager := WeatherManager.new()
	var source_weather := _make_weather("test_sunny", false)
	manager.test_weather = source_weather

	manager.start(0, CombatData.CombatType.COMMON)
	var selected := manager.get_current_weather()

	assert_eq(selected.id, "test_sunny")
	assert_false(selected == source_weather)
	selected.id = "mutated_copy"
	assert_eq(source_weather.id, "test_sunny")


func test_start_filters_weathers_by_boss_flag() -> void:
	var manager := WeatherManager.new()
	var fake_database := FakeWeatherDatabase.new()
	autofree(fake_database)
	fake_database.weathers = [
		_make_weather("boss_weather", true),
		_make_weather("common_weather", false),
	]
	var original_database := MainDatabase.weather_database
	MainDatabase.weather_database = fake_database

	manager.start(0, CombatData.CombatType.BOSS)
	var selected := manager.get_current_weather()

	MainDatabase.weather_database = original_database
	assert_true(selected.boss)
	assert_eq(selected.id, "boss_weather")


func test_get_current_weather_returns_selected_duplicate() -> void:
	var manager := WeatherManager.new()
	var source_weather := _make_weather("rainy", false)
	manager.test_weather = source_weather

	manager.start(0, CombatData.CombatType.COMMON)
	var selected := manager.get_current_weather()
	var selected_again := manager.get_current_weather()

	assert_eq(selected.id, "rainy")
	assert_true(selected == selected_again)
