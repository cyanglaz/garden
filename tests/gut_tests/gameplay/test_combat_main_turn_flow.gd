extends GutTest


class FakePlayer extends Player:
	var end_turn_calls := 0

	func handle_turn_end(_combat_main: CombatMain) -> void:
		end_turn_calls += 1
		await Util.await_for_tiny_time()


class FakePlantFieldContainer extends PlantFieldContainer:
	var end_turn_hook_calls := 0
	var handle_turn_end_calls := 0
	var force_bloom := false

	func trigger_end_turn_hooks(_combat_main: CombatMain) -> void:
		end_turn_hook_calls += 1
		await Util.await_for_tiny_time()

	func handle_turn_end() -> void:
		handle_turn_end_calls += 1

	func are_all_plants_bloom() -> bool:
		return force_bloom


class FakeWeatherMain extends WeatherMain:
	var apply_calls := 0
	var night_fall_calls := 0
	var new_day_calls := 0

	func apply_weather_abilities() -> void:
		apply_calls += 1
		await Util.await_for_tiny_time()

	func night_fall() -> void:
		night_fall_calls += 1
		await Util.await_for_tiny_time()

	func new_day() -> void:
		new_day_calls += 1
		await Util.await_for_tiny_time()


class TestCombatMain extends CombatMain:
	var start_turn_calls := 0
	var discard_all_tools_calls := 0
	var trigger_turn_end_cards_calls := 0

	func _start_turn() -> void:
		start_turn_calls += 1

	func _discard_all_tools() -> void:
		discard_all_tools_calls += 1
		await Util.await_for_tiny_time()

	func _trigger_turn_end_cards() -> void:
		trigger_turn_end_cards_calls += 1
		await Util.await_for_tiny_time()


class EndTurnButtonSpyCombatMain extends CombatMain:
	var end_turn_calls := 0

	func _end_turn() -> void:
		end_turn_calls += 1


func _attach_minimal_gui(cm: CombatMain) -> GUIToolCardContainer:
	var gui := GUICombatMain.new()
	autofree(gui)
	var card_container := GUIToolCardContainer.new()
	autofree(card_container)
	var card_holder := Control.new()
	autofree(card_holder)
	card_holder.size = Vector2(220, 70)
	card_container._container = card_holder
	card_container._card_size = GUIToolCardButton.SIZE.x
	gui.gui_tool_card_container = card_container
	cm.gui = gui
	return card_container


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


func test_set_is_mid_turn_propagates_to_gui_tool_card_container() -> void:
	var cm := CombatMain.new()
	autofree(cm)
	var card_container := _attach_minimal_gui(cm)

	cm.is_mid_turn = true
	assert_true(cm.is_mid_turn)
	assert_true(card_container.is_mid_turn)

	cm.is_mid_turn = false
	assert_false(cm.is_mid_turn)
	assert_false(card_container.is_mid_turn)


func test_end_turn_button_ignored_when_not_mid_turn() -> void:
	var cm := CombatMain.new()
	autofree(cm)
	_attach_minimal_gui(cm)
	cm.is_mid_turn = false

	var capture := _capture_queue_requests()
	cm._on_end_turn_button_pressed()
	_disconnect_capture(capture)

	assert_eq(capture.requests.size(), 0)


func test_end_turn_button_pushes_only_when_empty_request_and_invokes_end_turn() -> void:
	var cm := EndTurnButtonSpyCombatMain.new()
	autofree(cm)
	_attach_minimal_gui(cm)
	cm.is_mid_turn = true

	var capture := _capture_queue_requests()
	cm._on_end_turn_button_pressed()
	_disconnect_capture(capture)

	assert_eq(capture.requests.size(), 1)
	var request: CombatQueueRequest = capture.requests[0]
	assert_true(request.callback.is_valid())
	assert_true(request.only_when_empty)
	request.callback.call(cm)
	assert_eq(cm.end_turn_calls, 1)


func test_end_turn_sequence_calls_weather_apply_without_combat_arg_and_schedules_start_turn() -> void:
	var cm := TestCombatMain.new()
	autofree(cm)
	var card_container := _attach_minimal_gui(cm)

	var fake_player := FakePlayer.new()
	autofree(fake_player)
	cm.player = fake_player

	var fake_field := FakePlantFieldContainer.new()
	autofree(fake_field)
	cm.plant_field_container = fake_field

	var fake_weather := FakeWeatherMain.new()
	autofree(fake_weather)
	cm.weather_main = fake_weather

	cm.tool_manager = ToolManager.new([], card_container)
	cm.tool_manager.card_use_limit_reached = true

	var capture := _capture_queue_requests()
	await cm._end_turn()
	_disconnect_capture(capture)

	assert_false(cm.is_mid_turn)
	assert_eq(fake_player.end_turn_calls, 1)
	assert_eq(fake_field.end_turn_hook_calls, 1)
	assert_eq(fake_field.handle_turn_end_calls, 1)
	assert_eq(fake_weather.apply_calls, 1)
	assert_eq(fake_weather.night_fall_calls, 1)
	assert_eq(fake_weather.new_day_calls, 1)
	assert_false(cm.tool_manager.card_use_limit_reached)
	assert_eq(capture.requests.size(), 1)

	var request: CombatQueueRequest = capture.requests[0]
	assert_true(request.callback.is_valid())
	request.callback.call(cm)
	assert_eq(cm.start_turn_calls, 1)
