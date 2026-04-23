extends GutTest

# Tests for FieldStatus.queue_* methods — the migrated async hook API that now
# front-pushes CombatQueueRequest items instead of awaiting handlers directly.
# Inactive statuses should emit the request but have the callback no-op.


class TestFieldStatus extends FieldStatus:
	var handle_tool_application_calls := 0
	var handle_tool_discard_calls := 0
	var handle_add_water_calls := 0
	var handle_end_turn_calls := 0
	var last_discard_count := -1

	func _has_tool_application_hook(_plant: Plant) -> bool:
		return true

	func _handle_tool_application_hook(_plant: Plant, _combat_main: CombatMain) -> void:
		handle_tool_application_calls += 1

	func _has_tool_discard_hook(_count: int, _plant: Plant) -> bool:
		return true

	func _handle_tool_discard_hook(_plant: Plant, count: int, _combat_main: CombatMain) -> void:
		handle_tool_discard_calls += 1
		last_discard_count = count

	func _has_add_water_hook(_plant: Plant) -> bool:
		return true

	func _handle_add_water_hook(_plant: Plant) -> void:
		handle_add_water_calls += 1

	func _has_end_turn_hook(_plant: Plant) -> bool:
		return true

	func _handle_end_turn_hook(_combat_main: CombatMain, _plant: Plant) -> void:
		handle_end_turn_calls += 1


func _make_status() -> TestFieldStatus:
	var s := TestFieldStatus.new()
	add_child_autofree(s)
	s.status_data = StatusData.new()
	s.status_data.id = "test_status"
	return s


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


# ----- has_* gating -----------------------------------------------------------

func test_has_hooks_return_false_when_inactive() -> void:
	var s := _make_status()
	s.active = false
	assert_false(s.has_tool_application_hook(null))
	assert_false(s.has_tool_discard_hook(0, null))
	assert_false(s.has_add_water_hook(null))
	assert_false(s.has_end_turn_hook(null))


# ----- queue_tool_application_hook --------------------------------------------

func test_queue_tool_application_hook_emits_front_request() -> void:
	var s := _make_status()
	var capture := _capture_queue_requests()
	s.queue_tool_application_hook(null)
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)
	var request: CombatQueueRequest = capture.requests[0]
	assert_true(request.front)
	assert_true(request.callback.is_valid())


func test_queue_tool_application_hook_callback_invokes_handler_and_emits_triggered_when_active() -> void:
	var s := _make_status()
	var capture := _capture_queue_requests()
	s.queue_tool_application_hook(null)
	_disconnect_capture(capture)
	watch_signals(s)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(s.handle_tool_application_calls, 1)
	assert_signal_emitted(s, "triggered")


func test_queue_tool_application_hook_callback_is_noop_when_inactive() -> void:
	var s := _make_status()
	var capture := _capture_queue_requests()
	s.queue_tool_application_hook(null)
	_disconnect_capture(capture)
	s.active = false
	watch_signals(s)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(s.handle_tool_application_calls, 0)
	assert_signal_not_emitted(s, "triggered")


# ----- queue_tool_discard_hook ------------------------------------------------

func test_queue_tool_discard_hook_emits_front_request() -> void:
	var s := _make_status()
	var capture := _capture_queue_requests()
	s.queue_tool_discard_hook(null, 2)
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)
	assert_true((capture.requests[0] as CombatQueueRequest).front)


func test_queue_tool_discard_hook_callback_forwards_count_to_handler() -> void:
	var s := _make_status()
	var capture := _capture_queue_requests()
	s.queue_tool_discard_hook(null, 3)
	_disconnect_capture(capture)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(s.handle_tool_discard_calls, 1)
	assert_eq(s.last_discard_count, 3)


# ----- queue_add_water_hook ---------------------------------------------------

func test_queue_add_water_hook_emits_front_request() -> void:
	var s := _make_status()
	var capture := _capture_queue_requests()
	s.queue_add_water_hook(null)
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)
	assert_true((capture.requests[0] as CombatQueueRequest).front)


func test_queue_add_water_hook_callback_invokes_handler_when_active() -> void:
	var s := _make_status()
	var capture := _capture_queue_requests()
	s.queue_add_water_hook(null)
	_disconnect_capture(capture)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(s.handle_add_water_calls, 1)


# ----- handle_end_turn_hook (back-push, not front) ----------------------------

func test_handle_end_turn_hook_emits_back_request() -> void:
	var s := _make_status()
	var capture := _capture_queue_requests()
	s.handle_end_turn_hook(null)
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)
	# End-turn hooks are drained in order behind other work, so they push to the
	# back of the queue (front flag defaults to false on CombatQueueRequest).
	assert_false((capture.requests[0] as CombatQueueRequest).front)


func test_handle_end_turn_hook_callback_invokes_handler_when_active() -> void:
	var s := _make_status()
	var capture := _capture_queue_requests()
	s.handle_end_turn_hook(null)
	_disconnect_capture(capture)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(s.handle_end_turn_calls, 1)


# ----- handle_prevent_resource_update_value_hook (synchronous) ----------------

func test_handle_prevent_resource_update_value_hook_returns_false_when_inactive() -> void:
	var s := _make_status()
	s.active = false
	# FieldStatusBuried-style: return true for any call. But because the status
	# is inactive, container-level gate returns false.
	assert_false(s.handle_prevent_resource_update_value_hook("light", null, 0, 1))
