extends GutTest

# Tests for PlayerUpgrade.queue_* methods. Each helper builds a
# CombatQueueRequest with the appropriate front flag and pushes it via
# Events.request_combat_queue_push. Invoking the captured callback forwards to
# the virtual `_handle_*_hook` the subclasses override.


class TestPlayerUpgrade extends PlayerUpgrade:
	var activation_calls := 0
	var tool_application_calls := 0
	var last_tool_application_data: ToolData
	var pool_updated_calls := 0
	var last_pool: Array
	var discard_calls := 0
	var last_discard_tools: Array
	var exhaust_calls := 0
	var draw_calls := 0
	var stack_update_calls := 0
	var last_stack_update_id := ""
	var last_stack_update_diff := 0
	var hand_updated_calls := 0
	var plant_bloom_calls := 0
	var damage_taken_calls := 0
	var last_damage := 0
	var combat_end_calls := 0

	var _stack_value := 0

	func _set_stack(value: int) -> void:
		_stack_value = value

	func _get_stack() -> int:
		return _stack_value

	func _handle_activation_hook(_combat_main: CombatMain) -> void:
		activation_calls += 1

	func _handle_tool_application_hook(_combat_main: CombatMain, tool_data: ToolData) -> void:
		tool_application_calls += 1
		last_tool_application_data = tool_data

	func _handle_pool_updated_hook(_combat_main: CombatMain, pool: Array) -> void:
		pool_updated_calls += 1
		last_pool = pool

	func _handle_discard_hook(_combat_main: CombatMain, tool_datas: Array) -> void:
		discard_calls += 1
		last_discard_tools = tool_datas

	func _handle_exhaust_hook(_combat_main: CombatMain, _tool_datas: Array) -> void:
		exhaust_calls += 1

	func _handle_draw_hook(_combat_main: CombatMain, _tool_datas: Array) -> void:
		draw_calls += 1

	func _handle_stack_update_hook(_combat_main: CombatMain, id: String, diff: int) -> void:
		stack_update_calls += 1
		last_stack_update_id = id
		last_stack_update_diff = diff

	func _handle_hand_updated_hook(_combat_main: CombatMain) -> void:
		hand_updated_calls += 1

	func _handle_plant_bloom_hook(_combat_main: CombatMain) -> void:
		plant_bloom_calls += 1

	func _handle_damage_taken_hook(_combat_main: CombatMain, damage: int) -> void:
		damage_taken_calls += 1
		last_damage = damage

	func _handle_combat_end_hook(_combat_main: CombatMain) -> void:
		combat_end_calls += 1


func _make_upgrade() -> TestPlayerUpgrade:
	var u := TestPlayerUpgrade.new()
	add_child_autofree(u)
	u.data = ThingData.new()
	u.data.id = "test_upgrade"
	return u


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


# ----- queue_activation_hook --------------------------------------------------

func test_queue_activation_hook_emits_front_request() -> void:
	var u := _make_upgrade()
	var capture := _capture_queue_requests()
	u.queue_activation_hook()
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)
	assert_true((capture.requests[0] as CombatQueueRequest).front)


func test_queue_activation_hook_callback_invokes_handler() -> void:
	var u := _make_upgrade()
	var capture := _capture_queue_requests()
	u.queue_activation_hook()
	_disconnect_capture(capture)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(u.activation_calls, 1)


# ----- queue_tool_application_hook --------------------------------------------

func test_queue_tool_application_hook_emits_front_request() -> void:
	var u := _make_upgrade()
	var capture := _capture_queue_requests()
	u.queue_tool_application_hook(null)
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)
	assert_true((capture.requests[0] as CombatQueueRequest).front)


func test_queue_tool_application_hook_callback_forwards_tool_data() -> void:
	var u := _make_upgrade()
	var tool_data := ToolData.new()
	tool_data.id = "some_tool"
	var capture := _capture_queue_requests()
	u.queue_tool_application_hook(tool_data)
	_disconnect_capture(capture)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(u.tool_application_calls, 1)
	assert_eq(u.last_tool_application_data, tool_data)


# ----- queue_pool_updated_hook ------------------------------------------------

func test_queue_pool_updated_hook_emits_front_request() -> void:
	var u := _make_upgrade()
	var capture := _capture_queue_requests()
	u.queue_pool_updated_hook([])
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)
	assert_true((capture.requests[0] as CombatQueueRequest).front)


func test_queue_pool_updated_hook_callback_forwards_pool() -> void:
	var u := _make_upgrade()
	var td := ToolData.new()
	td.id = "foo"
	var capture := _capture_queue_requests()
	u.queue_pool_updated_hook([td])
	_disconnect_capture(capture)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(u.pool_updated_calls, 1)
	assert_eq(u.last_pool.size(), 1)
	assert_eq((u.last_pool[0] as ToolData).id, "foo")


# ----- queue_discard_hooks / queue_exhaust_hook / queue_draw_hook -------------

func test_queue_discard_hooks_emits_front_request_and_forwards_tool_datas() -> void:
	var u := _make_upgrade()
	var tool_data := ToolData.new()
	var capture := _capture_queue_requests()
	u.queue_discard_hooks([tool_data])
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)
	assert_true((capture.requests[0] as CombatQueueRequest).front)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(u.discard_calls, 1)
	assert_eq(u.last_discard_tools.size(), 1)


func test_queue_exhaust_hook_emits_front_request_and_invokes_handler() -> void:
	var u := _make_upgrade()
	var capture := _capture_queue_requests()
	u.queue_exhaust_hook([ToolData.new()])
	_disconnect_capture(capture)
	assert_true((capture.requests[0] as CombatQueueRequest).front)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(u.exhaust_calls, 1)


func test_queue_draw_hook_emits_front_request_and_invokes_handler() -> void:
	var u := _make_upgrade()
	var capture := _capture_queue_requests()
	u.queue_draw_hook([ToolData.new()])
	_disconnect_capture(capture)
	assert_true((capture.requests[0] as CombatQueueRequest).front)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(u.draw_calls, 1)


# ----- queue_stack_update_hook ------------------------------------------------

func test_queue_stack_update_hook_emits_front_request() -> void:
	var u := _make_upgrade()
	var capture := _capture_queue_requests()
	u.queue_stack_update_hook("foo", 2)
	_disconnect_capture(capture)
	assert_true((capture.requests[0] as CombatQueueRequest).front)


func test_queue_stack_update_hook_callback_forwards_id_and_diff() -> void:
	var u := _make_upgrade()
	var capture := _capture_queue_requests()
	u.queue_stack_update_hook("regen", 3)
	_disconnect_capture(capture)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(u.last_stack_update_id, "regen")
	assert_eq(u.last_stack_update_diff, 3)


# ----- queue_hand_updated_hook / queue_plant_bloom_hook -----------------------

func test_queue_hand_updated_hook_front_pushes_and_invokes_handler() -> void:
	var u := _make_upgrade()
	var capture := _capture_queue_requests()
	u.queue_hand_updated_hook()
	_disconnect_capture(capture)
	assert_true((capture.requests[0] as CombatQueueRequest).front)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(u.hand_updated_calls, 1)


func test_queue_plant_bloom_hook_front_pushes_and_invokes_handler() -> void:
	var u := _make_upgrade()
	var capture := _capture_queue_requests()
	u.queue_plant_bloom_hook()
	_disconnect_capture(capture)
	assert_true((capture.requests[0] as CombatQueueRequest).front)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(u.plant_bloom_calls, 1)


# ----- queue_damage_taken_hook ------------------------------------------------

func test_queue_damage_taken_hook_front_pushes_and_forwards_damage() -> void:
	var u := _make_upgrade()
	var capture := _capture_queue_requests()
	u.queue_damage_taken_hook(5)
	_disconnect_capture(capture)
	assert_true((capture.requests[0] as CombatQueueRequest).front)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(u.damage_taken_calls, 1)
	assert_eq(u.last_damage, 5)


# ----- queue_combat_end_hook --------------------------------------------------

func test_queue_combat_end_hook_back_pushes_and_invokes_handler() -> void:
	var u := _make_upgrade()
	var capture := _capture_queue_requests()
	u.queue_combat_end_hook()
	_disconnect_capture(capture)
	assert_eq(capture.requests.size(), 1)
	# combat_end is a tail-of-queue "cleanup" hook → does not front-push.
	assert_false((capture.requests[0] as CombatQueueRequest).front)
	await (capture.requests[0] as CombatQueueRequest).callback.call(null)
	assert_eq(u.combat_end_calls, 1)
