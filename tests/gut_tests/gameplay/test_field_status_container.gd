extends GutTest

# Tests for FieldStatusContainer's queue_* helpers. Each helper filters active
# statuses that match the hook predicate, reverses that list, and then asks
# every surviving status to `queue_*_hook` itself. Because each status-level
# queue_*_hook front-pushes a CombatQueueRequest, reversing here makes the
# combat queue drain in the original child order.


class RecordingStatus extends FieldStatus:
	var marker: String
	var events: Array
	var has_tool_app := false
	var has_tool_discard := false
	var has_add_water := false
	var has_end_turn := false
	var has_prevent_resource := false
	var prevent_return_value := false

	func queue_tool_application_hook(_plant: Plant) -> void:
		events.append("tool_app_%s" % marker)

	func queue_tool_discard_hook(_plant: Plant, count: int) -> void:
		events.append("tool_discard_%s_%d" % [marker, count])

	func queue_add_water_hook(_plant: Plant) -> void:
		events.append("add_water_%s" % marker)

	func handle_end_turn_hook(_plant: Plant) -> void:
		events.append("end_turn_%s" % marker)

	func has_tool_application_hook(_plant: Plant) -> bool:
		return active and has_tool_app

	func has_tool_discard_hook(_count: int, _plant: Plant) -> bool:
		return active and has_tool_discard

	func has_add_water_hook(_plant: Plant) -> bool:
		return active and has_add_water

	func has_end_turn_hook(_plant: Plant) -> bool:
		return active and has_end_turn

	func has_prevent_resource_update_value_hook(
		_resource_id: String, _plant: Plant, _old_value: int, _new_value: int
	) -> bool:
		return active and has_prevent_resource

	func handle_prevent_resource_update_value_hook(
		_resource_id: String, _plant: Plant, _old_value: int, _new_value: int
	) -> bool:
		events.append("prevent_%s" % marker)
		return prevent_return_value


func _make_status(
	marker: String,
	events: Array,
	opts: Dictionary = {}
) -> RecordingStatus:
	var s := RecordingStatus.new()
	autofree(s)
	s.marker = marker
	s.events = events
	s.status_data = StatusData.new()
	s.status_data.id = "test_%s" % marker
	s.has_tool_app = opts.get("tool_app", false)
	s.has_tool_discard = opts.get("tool_discard", false)
	s.has_add_water = opts.get("add_water", false)
	s.has_end_turn = opts.get("end_turn", false)
	s.has_prevent_resource = opts.get("prevent", false)
	s.prevent_return_value = opts.get("prevent_return", false)
	return s


func _make_container() -> FieldStatusContainer:
	var c := FieldStatusContainer.new()
	add_child_autofree(c)
	return c


# get_active_statuses() reverses get_children() internally, so children added
# in order [a, b, c] are returned as [c, b, a]. The queue_* helpers reverse
# again before calling queue_*_hook on each status. The net iteration order
# observed by the statuses is therefore [a, b, c] (add order). In production
# each status then front-pushes a CombatQueueRequest, so the queue drains in
# [c, b, a] order — matching the legacy "most recently added status fires
# first" semantics of the old synchronous handle_*_hook path.


func test_queue_tool_application_hooks_visits_statuses_in_post_reverse_order() -> void:
	var events: Array = []
	var container := _make_container()
	container.add_child(_make_status("a", events, {"tool_app": true}))
	container.add_child(_make_status("b", events, {"tool_app": true}))
	container.add_child(_make_status("c", events, {"tool_app": true}))
	container.queue_tool_application_hooks(null)
	assert_eq(events, ["tool_app_a", "tool_app_b", "tool_app_c"])


func test_queue_tool_application_hooks_skips_non_matching_statuses() -> void:
	var events: Array = []
	var container := _make_container()
	container.add_child(_make_status("a", events, {"tool_app": true}))
	container.add_child(_make_status("b", events, {}))
	container.add_child(_make_status("c", events, {"tool_app": true}))
	container.queue_tool_application_hooks(null)
	assert_eq(events, ["tool_app_a", "tool_app_c"])


func test_queue_tool_application_hooks_skips_inactive_statuses() -> void:
	var events: Array = []
	var container := _make_container()
	container.add_child(_make_status("a", events, {"tool_app": true}))
	var inactive := _make_status("b", events, {"tool_app": true})
	inactive.active = false
	container.add_child(inactive)
	container.queue_tool_application_hooks(null)
	assert_eq(events, ["tool_app_a"])


func test_queue_tool_discard_hooks_forwards_count() -> void:
	var events: Array = []
	var container := _make_container()
	container.add_child(_make_status("a", events, {"tool_discard": true}))
	container.add_child(_make_status("b", events, {"tool_discard": true}))
	container.queue_tool_discard_hooks(null, 5)
	assert_eq(events, ["tool_discard_a_5", "tool_discard_b_5"])


func test_queue_add_water_hooks_visits_each_matching_status() -> void:
	var events: Array = []
	var container := _make_container()
	container.add_child(_make_status("a", events, {"add_water": true}))
	container.add_child(_make_status("b", events, {"add_water": true}))
	container.add_child(_make_status("c", events, {"add_water": true}))
	container.queue_add_water_hooks(null)
	assert_eq(events, ["add_water_a", "add_water_b", "add_water_c"])


# queue_end_turn_hooks reverses too, even though handle_end_turn_hook itself
# back-pushes — the reverse keeps the original-order semantics consistent with
# the other helpers.
func test_queue_end_turn_hooks_visits_each_matching_status() -> void:
	var events: Array = []
	var container := _make_container()
	container.add_child(_make_status("a", events, {"end_turn": true}))
	container.add_child(_make_status("b", events, {"end_turn": true}))
	container.queue_end_turn_hooks(null)
	assert_eq(events, ["end_turn_a", "end_turn_b"])


# handle_prevent_resource_update_value_hook is synchronous and short-circuits
# when any status returns true. Order matches get_active_statuses() (reverse of
# child order) because container no longer reverses for this hook.
func test_handle_prevent_resource_short_circuits_on_first_true() -> void:
	var events: Array = []
	var container := _make_container()
	container.add_child(_make_status("a", events, {"prevent": true, "prevent_return": false}))
	container.add_child(_make_status("b", events, {"prevent": true, "prevent_return": true}))
	container.add_child(_make_status("c", events, {"prevent": true, "prevent_return": false}))
	var result := container.handle_prevent_resource_update_value_hook("light", null, 0, 1)
	assert_true(result)
	# Iteration is in get_active_statuses() order (reverse of add order): c, b, a.
	# Short-circuits after b returns true → "c" and "b" run, "a" does not.
	assert_eq(events, ["prevent_c", "prevent_b"])


func test_handle_prevent_resource_returns_false_when_none_prevent() -> void:
	var events: Array = []
	var container := _make_container()
	container.add_child(_make_status("a", events, {"prevent": true, "prevent_return": false}))
	container.add_child(_make_status("b", events, {"prevent": true, "prevent_return": false}))
	var result := container.handle_prevent_resource_update_value_hook("light", null, 0, 1)
	assert_false(result)


func test_handle_prevent_resource_returns_false_when_no_matching_status() -> void:
	var events: Array = []
	var container := _make_container()
	container.add_child(_make_status("a", events, {}))
	var result := container.handle_prevent_resource_update_value_hook("light", null, 0, 1)
	assert_false(result)
	assert_eq(events, [])
