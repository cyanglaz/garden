extends GutTest


class FakePlayer extends Player:
	var end_turn_calls := 0

	func queue_handle_turn_end(_combat_main: CombatMain) -> void:
		end_turn_calls += 1


class RecordingPlayerUpgradesManager extends PlayerUpgradesManager:
	var queued_tool_data: ToolData

	func queue_tool_application_hook(_combat_main: CombatMain, tool_data: ToolData) -> void:
		queued_tool_data = tool_data


class FakePlantFieldContainer extends PlantFieldContainer:
	var end_turn_hook_calls := 0
	var force_bloom := false

	func queue_end_turn_abilities(_combat_main: CombatMain) -> void:
		end_turn_hook_calls += 1

	func are_all_plants_bloom() -> bool:
		return force_bloom

	func clear_tool_indicators() -> void:
		pass


class FakeWeatherMain extends WeatherMain:
	var apply_calls := 0
	var night_fall_calls := 0
	var new_day_calls := 0

	func queue_weather_abilities() -> void:
		apply_calls += 1

	func night_fall() -> void:
		night_fall_calls += 1
		await Util.await_for_tiny_time()

	func new_day() -> void:
		new_day_calls += 1
		await Util.await_for_tiny_time()


class TestCombatMain extends CombatMain:
	var start_turn_calls := 0

	func _start_turn() -> void:
		start_turn_calls += 1


class EndTurnButtonSpyCombatMain extends CombatMain:
	var end_turn_calls := 0

	func _end_turn() -> void:
		end_turn_calls += 1


# GUICombatMain.toggle_all_ui touches @onready nodes that aren't available when
# the GUI is instantiated via .new() (no scene tree). Stub it out for tests.
class FakeGUICombatMain extends GUICombatMain:
	func toggle_all_ui(_on: bool) -> void:
		pass

	func clear_tool_selection() -> void:
		pass


class FakeDiscardGUIToolCardContainer extends GUIToolCardContainer:
	func animate_discard(_tool_datas: Array, _combat_main: CombatMain) -> void:
		await Util.await_for_tiny_time()


func _attach_minimal_gui(cm: CombatMain) -> GUIToolCardContainer:
	var gui := FakeGUICombatMain.new()
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
	cm.tool_manager = ToolManager.new([], card_container)
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


func _make_tool(id: String) -> ToolData:
	var tool := ToolData.new()
	tool.id = id
	return tool


func _make_tool_manager_with_hand(tools: Array[ToolData]) -> Dictionary:
	var container := FakeDiscardGUIToolCardContainer.new()
	var manager := ToolManager.new(tools, container)
	manager.tool_deck.draw_pool = manager.tool_deck.pool.duplicate()
	manager.tool_deck.draw(tools.size())
	return {"manager": manager, "container": container}


func test_set_is_mid_turn_propagates_to_gui_tool_card_container() -> void:
	var cm := CombatMain.new()
	autofree(cm)
	var card_container := _attach_minimal_gui(cm)

	cm.is_mid_turn = true
	assert_true(cm.is_mid_turn)
	assert_true(card_container.is_mid_turn)
	assert_true(cm.tool_manager.is_mid_turn)

	cm.is_mid_turn = false
	assert_false(cm.is_mid_turn)
	assert_false(card_container.is_mid_turn)
	assert_false(cm.tool_manager.is_mid_turn)


func test_end_turn_button_ignored_when_not_mid_turn() -> void:
	var cm := CombatMain.new()
	autofree(cm)
	_attach_minimal_gui(cm)
	cm.is_mid_turn = false

	var capture := _capture_queue_requests()
	cm._on_end_turn_button_pressed()
	_disconnect_capture(capture)

	assert_eq(capture.requests.size(), 0)

func test_end_turn_button_pushes_unique_request_and_invokes_end_turn() -> void:
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
	assert_eq(request.unique_id, "end_turn")
	request.callback.call(cm)
	assert_eq(cm.end_turn_calls, 1)


func test_discard_cards_forwards_not_end_turn_flag() -> void:
	var cm := CombatMain.new()
	autofree(cm)
	var tool := _make_tool("manual_discard")
	var ctx := _make_tool_manager_with_hand([tool])
	cm.tool_manager = ctx["manager"]
	var hand_snapshot := cm.tool_manager.tool_deck.hand.duplicate()
	var captured := {"end_turn": null}
	cm.tool_manager.tools_discarded.connect(
		func(_tools: Array, end_turn: bool) -> void: captured["end_turn"] = end_turn
	)

	await cm.discard_cards(hand_snapshot)

	assert_eq(captured["end_turn"], false)
	(ctx["container"] as FakeDiscardGUIToolCardContainer).free()


func test_queue_discard_all_cards_forwards_end_turn_flag() -> void:
	var cm := CombatMain.new()
	autofree(cm)
	var tool := _make_tool("end_turn_discard")
	var ctx := _make_tool_manager_with_hand([tool])
	cm.tool_manager = ctx["manager"]

	var captured := {"end_turn": null}
	cm.tool_manager.tools_discarded.connect(
		func(_tools: Array, end_turn: bool) -> void: captured["end_turn"] = end_turn
	)

	var capture := _capture_queue_requests()
	cm._queue_discard_all_cards(false)
	assert_eq(capture.requests.size(), 1)
	await (capture.requests[0] as CombatQueueRequest).callback.call(cm)
	_disconnect_capture(capture)

	assert_eq(captured["end_turn"], true)
	(ctx["container"] as FakeDiscardGUIToolCardContainer).free()

func test_end_turn_zeroes_energy_immediately() -> void:
	var cm := CombatMain.new()
	autofree(cm)
	_attach_minimal_gui(cm)

	var fake_player := FakePlayer.new()
	autofree(fake_player)
	cm.player = fake_player

	var fake_field := FakePlantFieldContainer.new()
	autofree(fake_field)
	cm.plant_field_container = fake_field

	var fake_weather := FakeWeatherMain.new()
	autofree(fake_weather)
	cm.weather_main = fake_weather

	cm.energy_tracker.setup(2, 3)

	var capture := _capture_queue_requests()
	cm._end_turn()
	_disconnect_capture(capture)

	assert_eq(cm.energy_tracker.value, 0)


func test_restore_energy_restores_to_max_when_energy_exceeds_max() -> void:
	var cm := TestCombatMain.new()
	autofree(cm)
	_attach_minimal_gui(cm)

	var fake_player := FakePlayer.new()
	autofree(fake_player)
	cm.player = fake_player

	var fake_field := FakePlantFieldContainer.new()
	autofree(fake_field)
	cm.plant_field_container = fake_field

	var fake_weather := FakeWeatherMain.new()
	autofree(fake_weather)
	cm.weather_main = fake_weather

	cm.energy_tracker.capped = false
	cm.energy_tracker.setup(5, 3)
	cm.is_mid_turn = true

	var capture := _capture_queue_requests()
	cm._end_turn()
	assert_eq(cm.energy_tracker.value, 0)

	var post_weather_request: CombatQueueRequest = capture.requests[0]
	await post_weather_request.callback.call(cm)

	var night_fall_request: CombatQueueRequest = capture.requests[1]
	var discard_all_cards_request: CombatQueueRequest = capture.requests[2]
	var end_turn_cleanup_request: CombatQueueRequest = capture.requests[3]
	await night_fall_request.callback.call(cm)
	await discard_all_cards_request.callback.call(cm)
	await end_turn_cleanup_request.callback.call(cm)

	var restore_energy_request: CombatQueueRequest = capture.requests[5]
	await restore_energy_request.callback.call(cm)
	_disconnect_capture(capture)

	assert_eq(cm.energy_tracker.value, 3)


func test_end_turn_sequence_enqueues_pipeline_and_cleanup_schedules_start_turn() -> void:
	var cm := TestCombatMain.new()
	autofree(cm)
	_attach_minimal_gui(cm)

	var fake_player := FakePlayer.new()
	autofree(fake_player)
	cm.player = fake_player

	var fake_field := FakePlantFieldContainer.new()
	autofree(fake_field)
	cm.plant_field_container = fake_field

	var fake_weather := FakeWeatherMain.new()
	autofree(fake_weather)
	cm.weather_main = fake_weather

	cm.tool_manager.card_use_limit_reached = true
	cm.energy_tracker.setup(1, 3)
	cm.is_mid_turn = true

	var capture := _capture_queue_requests()
	cm._end_turn()
	assert_eq(capture.requests.size(), 1)

	var post_weather_request: CombatQueueRequest = capture.requests[0]
	assert_true(post_weather_request.callback.is_valid())
	await post_weather_request.callback.call(cm)
	assert_eq(capture.requests.size(), 4)

	var night_fall_request: CombatQueueRequest = capture.requests[1]
	var discard_all_cards_request: CombatQueueRequest = capture.requests[2]
	var end_turn_cleanup_request: CombatQueueRequest = capture.requests[3]
	assert_true(night_fall_request.callback.is_valid())
	assert_true(discard_all_cards_request.callback.is_valid())
	assert_true(end_turn_cleanup_request.callback.is_valid())

	await night_fall_request.callback.call(cm)
	await discard_all_cards_request.callback.call(cm)
	await end_turn_cleanup_request.callback.call(cm)
	_disconnect_capture(capture)

	assert_false(cm.is_mid_turn)
	assert_eq(fake_player.end_turn_calls, 1)
	assert_eq(fake_field.end_turn_hook_calls, 1)
	assert_eq(fake_weather.apply_calls, 1)
	assert_eq(fake_weather.night_fall_calls, 1)
	assert_false(cm.tool_manager.card_use_limit_reached)
	assert_eq(capture.requests.size(), 7)

	var new_day_request: CombatQueueRequest = capture.requests[4]
	var restore_energy_request: CombatQueueRequest = capture.requests[5]
	var start_turn_request: CombatQueueRequest = capture.requests[6]
	await new_day_request.callback.call(cm)
	await restore_energy_request.callback.call(cm)
	await start_turn_request.callback.call(cm)
	assert_eq(cm.energy_tracker.value, 3)
	assert_eq(fake_weather.new_day_calls, 1)
	assert_eq(cm.start_turn_calls, 1)
