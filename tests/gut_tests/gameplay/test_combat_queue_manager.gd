extends GutTest

## Uses [CombatMain] instances that are never added to the tree so @onready/% nodes are not resolved.

func _make_combat_main() -> CombatMain:
	var cm := CombatMain.new()
	autofree(cm)
	return cm


func _make_queue(cm: CombatMain) -> CombatQueueManager:
	var q := CombatQueueManager.new()
	q.setup(cm)
	return q

func _make_item(callback: Callable) -> CombatQueueItem:
	var item := CombatQueueItem.new()
	item.callback = callback
	return item

func _make_request(
	callback: Callable,
	front: bool = false,
	unique_id: String = "",
	finish_callback: Callable = Callable(),
	only_when_empty: bool = false
):
	var request = CombatQueueRequest.new()
	request.callback = callback
	request.front = front
	request.unique_id = unique_id
	request.finish_callback = finish_callback
	request.only_when_empty = only_when_empty
	return request


func _await_queue_idle(q: CombatQueueManager) -> void:
	var safety := 0
	while q.is_queue_busy() or q.get_queue_size() > 0:
		await get_tree().process_frame
		safety += 1
		assert_lt(safety, 120, "queue should drain")


func _append_async_slice(order: Array) -> void:
	order.append("a_start")
	await (Engine.get_main_loop() as SceneTree).create_timer(0.02).timeout
	order.append("a_end")


func _blocking_slice(order: Array) -> void:
	order.append("block_start")
	await (Engine.get_main_loop() as SceneTree).create_timer(0.05).timeout
	order.append("block_end")


func test_push_back_runs_callables_fifo() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_items(
		false,
		[
			_make_item(func(_c: CombatMain) -> void: order.append("a")),
			_make_item(func(_c: CombatMain) -> void: order.append("b")),
		],
	)
	await _await_queue_idle(q)
	assert_eq(order, ["a", "b"])


func test_push_front_batch_preserves_order_on_empty_queue() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_items(
		true,
		[
			_make_item(func(_c: CombatMain) -> void: order.append("h1")),
			_make_item(func(_c: CombatMain) -> void: order.append("h2")),
			_make_item(func(_c: CombatMain) -> void: order.append("h3")),
		],
	)
	await _await_queue_idle(q)
	assert_eq(order, ["h1", "h2", "h3"])


func test_push_front_while_busy_queues_before_remaining_backlog_not_mid_item() -> void:
	## While the worker is awaiting the current callable, new `push_items(front, …)` prepends to the
	## queue but does not interrupt the in-flight item; prepended work runs after it completes.
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_items(false, [_make_item(func(_c: CombatMain) -> void: await _blocking_slice(order))])
	q.push_items(true, [_make_item(func(_c: CombatMain) -> void: order.append("urgent"))])
	await _await_queue_idle(q)
	assert_eq(order, ["block_start", "block_end", "urgent"])


func test_push_back_after_front_batch_appends_in_order() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_items(
		true,
		[
			_make_item(func(_c: CombatMain) -> void: order.append("h1")),
			_make_item(func(_c: CombatMain) -> void: order.append("h2")),
		],
	)
	q.push_items(false, [_make_item(func(_c: CombatMain) -> void: order.append("tail"))])
	await _await_queue_idle(q)
	assert_eq(order, ["h1", "h2", "tail"])


func test_async_callable_completes_before_next_item() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_items(
		false,
		[
			_make_item(func(_c: CombatMain) -> void: await _append_async_slice(order)),
			_make_item(func(_c: CombatMain) -> void: order.append("b")),
		],
	)
	await _await_queue_idle(q)
	assert_eq(order, ["a_start", "a_end", "b"])


func test_staged_items_allow_front_insert_between_stages() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	var pre_stage := func(_c: CombatMain) -> void:
		order.append("pre_start")
		q.push_items(true, [_make_item(func(_c2: CombatMain) -> void: order.append("urgent"))])
		order.append("pre_end")
	q.push_items(
		false,
		[
			_make_item(pre_stage),
			_make_item(func(_c: CombatMain) -> void: order.append("apply")),
			_make_item(func(_c: CombatMain) -> void: order.append("finish")),
		],
	)
	await _await_queue_idle(q)
	assert_eq(order, ["pre_start", "pre_end", "urgent", "apply", "finish"])


func test_push_request_uses_front_and_callback() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_items(false, [_make_item(func(_c: CombatMain) -> void: await _blocking_slice(order))])
	q.push_request(_make_request(func(_c: CombatMain) -> void: order.append("tail")))
	q.push_request(_make_request(func(_c: CombatMain) -> void: order.append("front"), true))
	await _await_queue_idle(q)
	assert_eq(order, ["block_start", "block_end", "front", "tail"])


func test_push_request_with_unique_id_dedupes_until_processed() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_request(
		_make_request(
			func(_c: CombatMain) -> void:
				order.append("once")
				await (Engine.get_main_loop() as SceneTree).create_timer(0.02).timeout,
			false,
			"same_id"
		)
	)
	q.push_request(_make_request(func(_c: CombatMain) -> void: order.append("ignored"), false, "same_id"))
	await _await_queue_idle(q)
	assert_eq(order, ["once"])
	q.push_request(_make_request(func(_c: CombatMain) -> void: order.append("again"), false, "same_id"))
	await _await_queue_idle(q)
	assert_eq(order, ["once", "again"])


func test_push_request_calls_finish_callback_after_item_callback() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_request(
		_make_request(
			func(_c: CombatMain) -> void:
				order.append("main_start")
				await (Engine.get_main_loop() as SceneTree).create_timer(0.01).timeout
				order.append("main_end"),
			false,
			"",
			func(_c: CombatMain) -> void: order.append("finish")
		)
	)
	await _await_queue_idle(q)
	assert_eq(order, ["main_start", "main_end", "finish"])


func test_only_when_empty_item_is_discarded_when_queue_is_busy() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_items(false, [_make_item(func(_c: CombatMain) -> void: await _blocking_slice(order))])
	var gated_item := _make_item(func(_c: CombatMain) -> void: order.append("should_not_run"))
	gated_item.only_when_empty = true
	q.push_items(false, [gated_item])
	await _await_queue_idle(q)
	assert_eq(order, ["block_start", "block_end"])


func test_only_when_empty_request_is_discarded_when_queue_is_busy() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_items(false, [_make_item(func(_c: CombatMain) -> void: await _blocking_slice(order))])
	q.push_request(
		_make_request(
			func(_c: CombatMain) -> void: order.append("should_not_run"),
			false,
			"",
			Callable(),
			true
		)
	)
	await _await_queue_idle(q)
	assert_eq(order, ["block_start", "block_end"])


func test_only_when_empty_request_runs_when_queue_is_idle() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_request(
		_make_request(
			func(_c: CombatMain) -> void: order.append("runs"),
			false,
			"",
			Callable(),
			true
		)
	)
	await _await_queue_idle(q)
	assert_eq(order, ["runs"])


func test_empty_push_items_does_not_mark_busy() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	q.push_items(false, [])
	assert_false(q.is_queue_busy())
	assert_eq(q.get_queue_size(), 0)
