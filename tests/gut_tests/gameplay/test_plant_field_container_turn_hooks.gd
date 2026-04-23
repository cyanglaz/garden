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

	# Status markers this plant "owns" — simulates the per-plant statuses that
	# FieldStatusContainer.queue_tool_application_hooks would front-push.
	# Left empty by default so tests can opt-in.
	var status_markers: Array = []

	func queue_tool_application_hooks() -> void:
		# Mirrors FieldStatusContainer.queue_tool_application_hooks: reverse the
		# owned statuses and front-push one CombatQueueRequest per status so the
		# combat queue ends up with them in their original order.
		var owned := status_markers.duplicate()
		owned.reverse()
		for status_marker: String in owned:
			var request := CombatQueueRequest.new()
			request.front = true
			var plant_marker := marker
			request.callback = func(_cm: CombatMain) -> void:
				events.append("tool_app_%s_%s" % [plant_marker, status_marker])
			Events.request_combat_queue_push.emit(request)

	func end_turn_cleanup() -> void:
		events.append("end_turn_cleanup_%s" % marker)


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
			"end_turn_cleanup_p3", "end_turn_cleanup_p2", "end_turn_cleanup_p1"
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
		["start_p2", "start_p1", "end_p1", "end_p2", "end_turn_cleanup_p2", "end_turn_cleanup_p1"]
	)


func _make_plant_with_statuses(marker: String, events: Array, status_markers: Array) -> FakePlant:
	var plant := FakePlant.new(marker, events)
	plant.status_markers = status_markers
	return plant


func _attach_queue_manager() -> CombatQueueManager:
	var cm := CombatMain.new()
	autofree(cm)
	var q := CombatQueueManager.new()
	q.setup(cm)
	Events.request_combat_queue_push.connect(q.push_request)
	return q


func _detach_queue_manager(q: CombatQueueManager) -> void:
	if Events.request_combat_queue_push.is_connected(q.push_request):
		Events.request_combat_queue_push.disconnect(q.push_request)


func _await_queue_idle(q: CombatQueueManager) -> void:
	var safety := 0
	while q.is_queue_busy() or q.get_queue_size() > 0:
		await get_tree().process_frame
		safety += 1
		assert_lt(safety, 120, "queue should drain")


# Runs `body` inside a dispatched queue item so that front-pushes emitted from
# within it accumulate in the queue (mirroring how
# ToolManager._queue_tool_application_stages wraps the hook enqueuing in a
# pre-hook queue callback). Otherwise the queue would drain synchronously
# between each emit and observed order would not reflect production.
func _run_inside_dispatched_item(body: Callable) -> void:
	var request := CombatQueueRequest.new()
	request.callback = func(_cm: CombatMain) -> void: body.call()
	Events.request_combat_queue_push.emit(request)


# Each plant front-pushes one request per status. The fix reverses `plants`
# before iterating so that, once the real combat queue drains, hooks execute
# in the original plant order (p1 → p2 → p3) matching the legacy
# `for plant in plants: await plant.handle_tool_application_hook` semantics.
func test_queue_tool_application_hooks_drains_in_plant_order() -> void:
	var q := _attach_queue_manager()
	var field_container := PlantFieldContainer.new()
	autofree(field_container)
	var hook_log: Array = []
	var p1 := _make_plant_with_statuses("p1", hook_log, ["a", "b"])
	var p2 := _make_plant_with_statuses("p2", hook_log, ["c"])
	var p3 := _make_plant_with_statuses("p3", hook_log, ["d", "e"])
	field_container.plants = [p1, p2, p3]
	for plant in field_container.plants:
		autofree(plant)

	_run_inside_dispatched_item(func() -> void: field_container.queue_tool_application_hooks())
	await _await_queue_idle(q)
	_detach_queue_manager(q)

	assert_eq(
		hook_log,
		[
			"tool_app_p1_a", "tool_app_p1_b",
			"tool_app_p2_c",
			"tool_app_p3_d", "tool_app_p3_e",
		]
	)


# Plants with no statuses emit nothing even when siblings have statuses.
func test_queue_tool_application_hooks_skips_plants_without_statuses() -> void:
	var q := _attach_queue_manager()
	var field_container := PlantFieldContainer.new()
	autofree(field_container)
	var hook_log: Array = []
	var p1 := _make_plant_with_statuses("p1", hook_log, ["only"])
	var p2 := _make_plant_with_statuses("p2", hook_log, [])
	var p3 := _make_plant_with_statuses("p3", hook_log, ["last"])
	field_container.plants = [p1, p2, p3]
	for plant in field_container.plants:
		autofree(plant)

	_run_inside_dispatched_item(func() -> void: field_container.queue_tool_application_hooks())
	await _await_queue_idle(q)
	_detach_queue_manager(q)

	assert_eq(hook_log, ["tool_app_p1_only", "tool_app_p3_last"])


# Front-pushed tool-application hooks must not leapfrog work that was already
# pushed to the back (e.g. the apply-actions and finish stages that
# ToolManager._queue_tool_application_stages enqueues around them).
func test_queue_tool_application_hooks_front_pushes_run_before_trailing_back_items() -> void:
	var q := _attach_queue_manager()
	var field_container := PlantFieldContainer.new()
	autofree(field_container)
	var hook_log: Array = []
	var p1 := _make_plant_with_statuses("p1", hook_log, ["a"])
	var p2 := _make_plant_with_statuses("p2", hook_log, ["b"])
	field_container.plants = [p1, p2]
	for plant in field_container.plants:
		autofree(plant)

	_run_inside_dispatched_item(func() -> void: field_container.queue_tool_application_hooks())
	var apply_request := CombatQueueRequest.new()
	apply_request.callback = func(_cm: CombatMain) -> void: hook_log.append("apply")
	Events.request_combat_queue_push.emit(apply_request)
	var finish_request := CombatQueueRequest.new()
	finish_request.callback = func(_cm: CombatMain) -> void: hook_log.append("finish")
	Events.request_combat_queue_push.emit(finish_request)

	await _await_queue_idle(q)
	_detach_queue_manager(q)

	assert_eq(hook_log, ["tool_app_p1_a", "tool_app_p2_b", "apply", "finish"])


func test_queue_tool_application_hooks_no_op_when_no_plants() -> void:
	var field_container := PlantFieldContainer.new()
	autofree(field_container)
	var capture := _capture_queue_requests()
	field_container.queue_tool_application_hooks()
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 0)
