extends GutTest


class FakePlant extends Plant:
	var marker: String
	var events: Array
	var delay_seconds := 0.0

	func _init(p_marker: String, p_events: Array, p_delay_seconds: float = 0.0) -> void:
		marker = p_marker
		events = p_events
		delay_seconds = p_delay_seconds

	func queue_end_turn_abilities(_combat_main: CombatMain) -> void:
		events.append("start_%s" % marker)
		if delay_seconds > 0.0:
			var request := CombatQueueRequest.new()
			request.callback = func(_cm: CombatMain) -> void:
				await (Engine.get_main_loop() as SceneTree).create_timer(delay_seconds).timeout
				events.append("end_%s" % marker)
			Events.request_combat_queue_push.emit(request)
		else:
			events.append("end_%s" % marker)

	func queue_tool_application_hooks() -> void:
		events.append("tool_app_%s" % marker)

	func handle_turn_end() -> void:
		events.append("turn_end_%s" % marker)


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


func test_queue_end_turn_abilities_runs_reverse_order() -> void:
	var field_container := PlantFieldContainer.new()
	autofree(field_container)
	var hook_log: Array = []
	field_container.plants = [
		FakePlant.new("p1", hook_log),
		FakePlant.new("p2", hook_log),
		FakePlant.new("p3", hook_log),
	]
	for plant in field_container.plants:
		autofree(plant)

	var capture := _capture_queue_requests()
	field_container.queue_end_turn_abilities(null)
	_disconnect_capture(capture)

	assert_eq(
		hook_log,
		["start_p3", "end_p3", "start_p2", "end_p2", "start_p1", "end_p1"]
	)
	assert_eq(capture.requests.size(), 3)

	for request: CombatQueueRequest in capture.requests:
		request.callback.call(null)

	assert_eq(
		hook_log,
		[
			"start_p3", "end_p3", "start_p2", "end_p2", "start_p1", "end_p1",
			"turn_end_p3", "turn_end_p2", "turn_end_p1"
		]
	)


func test_queue_end_turn_abilities_defers_delayed_end_through_combat_queue() -> void:
	var field_container := PlantFieldContainer.new()
	autofree(field_container)
	var hook_log: Array = []
	var p1 := FakePlant.new("p1", hook_log, 0.0)
	var p2 := FakePlant.new("p2", hook_log, 0.03)
	autofree(p1)
	autofree(p2)
	field_container.plants = [p1, p2]

	var capture := _capture_queue_requests()
	field_container.queue_end_turn_abilities(null)
	_disconnect_capture(capture)

	assert_eq(hook_log, ["start_p2", "start_p1", "end_p1"])
	assert_eq(capture.requests.size(), 3)

	await capture.requests[0].callback.call(null)
	assert_eq(hook_log, ["start_p2", "start_p1", "end_p1", "end_p2"])

	capture.requests[1].callback.call(null)
	capture.requests[2].callback.call(null)
	assert_eq(
		hook_log,
		["start_p2", "start_p1", "end_p1", "end_p2", "turn_end_p2", "turn_end_p1"]
	)


func test_queue_tool_application_hooks_calls_every_plant_in_order() -> void:
	var field_container := PlantFieldContainer.new()
	autofree(field_container)
	var hook_log: Array = []
	field_container.plants = [
		FakePlant.new("p1", hook_log),
		FakePlant.new("p2", hook_log),
		FakePlant.new("p3", hook_log),
	]
	for plant in field_container.plants:
		autofree(plant)

	field_container.queue_tool_application_hooks()

	assert_eq(hook_log, ["tool_app_p1", "tool_app_p2", "tool_app_p3"])


func test_queue_tool_application_hooks_no_op_when_no_plants() -> void:
	var field_container := PlantFieldContainer.new()
	autofree(field_container)
	# No plants in the container; should not throw and should emit no requests.
	var capture := _capture_queue_requests()
	field_container.queue_tool_application_hooks()
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 0)
