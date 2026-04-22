extends GutTest


class FakeWeatherMain extends WeatherMain:
	var removed_field_indices: Array = []

	func remove_weather_ability_at_field_index(field_index: int) -> void:
		removed_field_indices.append(field_index)


class FakePlayer extends Node2D:
	var current_field_index := 0


class FakeCombatMain extends CombatMain:
	func _init():
		pass


func _make_combat_main(field_index: int) -> FakeCombatMain:
	var cm := FakeCombatMain.new()
	var player := FakePlayer.new()
	player.current_field_index = field_index
	cm.player = player
	var weather := FakeWeatherMain.new()
	cm.weather_main = weather
	autofree(cm)
	autofree(player)
	autofree(weather)
	return cm


func test_apply_tool_removes_weather_ability_at_current_field() -> void:
	var cm := _make_combat_main(2)
	await ToolScriptNullZone.new().apply_tool(cm, null, [])
	assert_eq((cm.weather_main as FakeWeatherMain).removed_field_indices, [2])


func test_apply_tool_uses_player_field_index_zero() -> void:
	var cm := _make_combat_main(0)
	await ToolScriptNullZone.new().apply_tool(cm, null, [])
	assert_eq((cm.weather_main as FakeWeatherMain).removed_field_indices, [0])


func test_apply_tool_uses_player_field_index_four() -> void:
	var cm := _make_combat_main(4)
	await ToolScriptNullZone.new().apply_tool(cm, null, [])
	assert_eq((cm.weather_main as FakeWeatherMain).removed_field_indices, [4])
