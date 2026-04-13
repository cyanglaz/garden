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
			CombatQueueCallableItem.new(func(_c: CombatMain) -> void: order.append("a")),
			CombatQueueCallableItem.new(func(_c: CombatMain) -> void: order.append("b")),
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
			CombatQueueCallableItem.new(func(_c: CombatMain) -> void: order.append("h1")),
			CombatQueueCallableItem.new(func(_c: CombatMain) -> void: order.append("h2")),
			CombatQueueCallableItem.new(func(_c: CombatMain) -> void: order.append("h3")),
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
	q.push_items(false, [CombatQueueCallableItem.new(func(_c: CombatMain) -> void: await _blocking_slice(order))])
	q.push_items(true, [CombatQueueCallableItem.new(func(_c: CombatMain) -> void: order.append("urgent"))])
	await _await_queue_idle(q)
	assert_eq(order, ["block_start", "block_end", "urgent"])


func test_push_back_after_front_batch_appends_in_order() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_items(
		true,
		[
			CombatQueueCallableItem.new(func(_c: CombatMain) -> void: order.append("h1")),
			CombatQueueCallableItem.new(func(_c: CombatMain) -> void: order.append("h2")),
		],
	)
	q.push_items(false, [CombatQueueCallableItem.new(func(_c: CombatMain) -> void: order.append("tail"))])
	await _await_queue_idle(q)
	assert_eq(order, ["h1", "h2", "tail"])


func test_async_callable_completes_before_next_item() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	var order: Array = []
	q.push_items(
		false,
		[
			CombatQueueCallableItem.new(func(_c: CombatMain) -> void: await _append_async_slice(order)),
			CombatQueueCallableItem.new(func(_c: CombatMain) -> void: order.append("b")),
		],
	)
	await _await_queue_idle(q)
	assert_eq(order, ["a_start", "a_end", "b"])


func test_empty_push_items_does_not_mark_busy() -> void:
	var cm := _make_combat_main()
	var q := _make_queue(cm)
	q.push_items(false, [])
	assert_false(q.is_queue_busy())
	assert_eq(q.get_queue_size(), 0)


func test_push_without_setup_does_not_enqueue() -> void:
	var q := CombatQueueManager.new()
	q.push_items(false, [CombatQueueCallableItem.new(func(_c: CombatMain) -> void: pass)])
	assert_push_error("setup")
	assert_eq(q.get_queue_size(), 0)
