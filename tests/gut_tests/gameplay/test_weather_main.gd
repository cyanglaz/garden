extends GutTest


class FakeWeatherAbilityContainer extends WeatherAbilityContainer:
	var apply_calls := 0
	var clear_calls := 0

	func apply_weather_actions() -> void:
		apply_calls += 1

	func clear_all_weather_abilities() -> void:
		clear_calls += 1


class FakeWeather extends Weather:
	var stop_calls := 0

	func stop() -> void:
		stop_calls += 1


func test_apply_weather_abilities_delegates_to_ability_container() -> void:
	var weather_main := WeatherMain.new()
	autofree(weather_main)
	var ability_container := FakeWeatherAbilityContainer.new()
	autofree(ability_container)
	weather_main._weather_ability_container = ability_container

	weather_main.apply_weather_abilities()

	assert_eq(ability_container.apply_calls, 1)


func test_level_end_stop_clears_current_weather_and_abilities() -> void:
	var weather_main := WeatherMain.new()
	autofree(weather_main)
	var ability_container := FakeWeatherAbilityContainer.new()
	autofree(ability_container)
	weather_main._weather_ability_container = ability_container

	var weather := FakeWeather.new()
	autofree(weather)
	weather_main._current_weather = weather
	weather_main.level_end_stop()

	assert_eq(weather.stop_calls, 1)
	assert_true(weather.is_queued_for_deletion())
	assert_eq(ability_container.clear_calls, 1)
	assert_eq(weather_main._current_weather, null)
