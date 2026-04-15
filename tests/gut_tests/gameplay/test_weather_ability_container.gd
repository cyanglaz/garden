extends GutTest


class FakeWeatherAbility extends WeatherAbility:
	var marker := ""
	var apply_log: Array
	var hide_icon_calls := 0
	var apply_to_player_calls := 0
	var apply_to_plant_calls := 0

	func _init(p_marker: String, p_apply_log: Array) -> void:
		marker = p_marker
		apply_log = p_apply_log

	func hide_icon() -> void:
		hide_icon_calls += 1

	func apply_to_player(_combat_main: CombatMain) -> void:
		apply_to_player_calls += 1
		apply_log.append("player_%s" % marker)
		await Util.await_for_tiny_time()

	func apply_to_plant(_plant: Plant, _combat_main: CombatMain) -> void:
		apply_to_plant_calls += 1
		apply_log.append("plant_%s" % marker)
		await Util.await_for_tiny_time()


class FakeWeatherAnimationContainer extends WeatherAbilityAnimationContainer:
	var run_calls: Array = []

	func run_animation(weather_ability: WeatherAbility, target_position: Vector2, blocked_by_player: bool) -> void:
		run_calls.append(
			{
				"ability": weather_ability,
				"target": target_position,
				"blocked_by_player": blocked_by_player,
			}
		)
		await Util.await_for_tiny_time()


class FakePlant extends Plant:
	func _init(p_global_position: Vector2) -> void:
		global_position = p_global_position


class FakePlayer extends Player:
	func _set_current_field_index(value: int) -> void:
		current_field_index = value


func _capture_queue_requests() -> Dictionary:
	var capture := {"requests": []}
	var callable := func(request: CombatQueueRequest) -> void:
		capture.requests.append(request)
	if Events.request_combat_queue_push.is_connected(callable):
		Events.request_combat_queue_push.disconnect(callable)
	Events.request_combat_queue_push.connect(callable)
	capture["callable"] = callable
	return capture


func _disconnect_capture(capture: Dictionary) -> void:
	var callable: Callable = capture["callable"]
	if Events.request_combat_queue_push.is_connected(callable):
		Events.request_combat_queue_push.disconnect(callable)


func _make_combat_main_with_plants(player_index: int = 0) -> CombatMain:
	var cm := CombatMain.new()
	autofree(cm)
	var player := FakePlayer.new()
	autofree(player)
	player.current_field_index = player_index
	cm.player = player

	var pfc := PlantFieldContainer.new()
	autofree(pfc)
	var p0 := FakePlant.new(Vector2(10, 20))
	var p1 := FakePlant.new(Vector2(30, 40))
	var p2 := FakePlant.new(Vector2(50, 60))
	autofree(p0)
	autofree(p1)
	autofree(p2)
	pfc.plants = [p0, p1, p2]
	cm.plant_field_container = pfc
	return cm


func test_apply_weather_actions_noop_when_empty() -> void:
	var container := WeatherAbilityContainer.new()
	autofree(container)
	container.weather_abilities = []

	var capture := _capture_queue_requests()
	await container.apply_weather_actions()
	_disconnect_capture(capture)

	assert_eq(capture.requests.size(), 0)


func test_apply_weather_actions_emits_queue_requests_in_desc_field_order() -> void:
	var container := WeatherAbilityContainer.new()
	autofree(container)
	var apply_log: Array = []
	var a0 := FakeWeatherAbility.new("f0", apply_log)
	a0.field_index = 0
	var a2 := FakeWeatherAbility.new("f2", apply_log)
	a2.field_index = 2
	var a1 := FakeWeatherAbility.new("f1", apply_log)
	a1.field_index = 1
	autofree(a0)
	autofree(a2)
	autofree(a1)
	container.weather_abilities = [a0, a2, a1]
	var animation_container := FakeWeatherAnimationContainer.new()
	autofree(animation_container)
	container.weather_ability_animation_container = animation_container

	var cm := _make_combat_main_with_plants(4)
	var capture := _capture_queue_requests()
	container.call("apply_weather_actions")
	assert_eq(capture.requests.size(), 3)

	for request: CombatQueueRequest in capture.requests:
		await request.callback.call(cm)
		await request.finish_callback.call(cm)
	_disconnect_capture(capture)

	assert_eq(apply_log, ["plant_f2", "plant_f1", "plant_f0"])


func test_apply_weather_actions_waits_until_last_finish_callback() -> void:
	var container := WeatherAbilityContainer.new()
	autofree(container)
	var apply_log: Array = []
	var a0 := FakeWeatherAbility.new("f0", apply_log)
	a0.field_index = 0
	var a1 := FakeWeatherAbility.new("f1", apply_log)
	a1.field_index = 1
	autofree(a0)
	autofree(a1)
	container.weather_abilities = [a0, a1]
	var animation_container := FakeWeatherAnimationContainer.new()
	autofree(animation_container)
	container.weather_ability_animation_container = animation_container

	var cm := _make_combat_main_with_plants(3)
	var capture := _capture_queue_requests()
	container.call("apply_weather_actions")
	assert_eq(capture.requests.size(), 2)

	await capture.requests[0].callback.call(cm)
	await capture.requests[0].finish_callback.call(cm)
	assert_eq(container.weather_abilities.size(), 1)

	await capture.requests[1].callback.call(cm)
	await capture.requests[1].finish_callback.call(cm)
	_disconnect_capture(capture)

	assert_eq(container.weather_abilities.size(), 0)


func test_apply_weather_ability_targets_player_when_field_matches_player_index() -> void:
	var container := WeatherAbilityContainer.new()
	autofree(container)
	var apply_log: Array = []
	var ability := FakeWeatherAbility.new("same_field", apply_log)
	autofree(ability)
	ability.field_index = 1
	var animation_container := FakeWeatherAnimationContainer.new()
	autofree(animation_container)
	container.weather_ability_animation_container = animation_container

	var cm := _make_combat_main_with_plants(1)
	cm.player.global_position = Vector2(101, 202)

	await container._apply_weather_ability(ability, cm)

	assert_eq(ability.hide_icon_calls, 1)
	assert_eq(ability.apply_to_player_calls, 1)
	assert_eq(ability.apply_to_plant_calls, 0)
	assert_eq(animation_container.run_calls.size(), 1)
	assert_true(animation_container.run_calls[0]["blocked_by_player"])
	assert_eq(animation_container.run_calls[0]["target"], cm.player.global_position)


func test_apply_weather_ability_targets_plant_when_field_differs() -> void:
	var container := WeatherAbilityContainer.new()
	autofree(container)
	var apply_log: Array = []
	var ability := FakeWeatherAbility.new("other_field", apply_log)
	autofree(ability)
	ability.field_index = 2
	var animation_container := FakeWeatherAnimationContainer.new()
	autofree(animation_container)
	container.weather_ability_animation_container = animation_container

	var cm := _make_combat_main_with_plants(0)
	var expected_target: Vector2 = cm.plant_field_container.plants[2].global_position

	await container._apply_weather_ability(ability, cm)

	assert_eq(ability.hide_icon_calls, 1)
	assert_eq(ability.apply_to_player_calls, 0)
	assert_eq(ability.apply_to_plant_calls, 1)
	assert_eq(animation_container.run_calls.size(), 1)
	assert_false(animation_container.run_calls[0]["blocked_by_player"])
	assert_eq(animation_container.run_calls[0]["target"], expected_target)


func test_handle_weather_ability_applied_emits_done_when_last_removed() -> void:
	var container := WeatherAbilityContainer.new()
	autofree(container)
	var apply_log: Array = []
	var a0 := FakeWeatherAbility.new("a0", apply_log)
	var a1 := FakeWeatherAbility.new("a1", apply_log)
	autofree(a0)
	autofree(a1)
	container.weather_abilities = [a0, a1]

	container._handle_weather_ability_applied(a0, null)
	assert_eq(container.weather_abilities.size(), 1)

	container._handle_weather_ability_applied(a1, null)
	assert_eq(container.weather_abilities.size(), 0)
