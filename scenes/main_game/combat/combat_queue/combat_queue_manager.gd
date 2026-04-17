class_name CombatQueueManager
extends RefCounted

## Serial async queue for combat steps. Add as a child of [CombatMain] and call [method setup]
## before [method push_items].

var _combat_main: CombatMain:
	set = _set_combat_main,
	get = _get_combat_main

var _weak_combat_main: WeakRef = weakref(null)
var _queue: Array = []
var _processing: bool = false
var _queued_unique_ids: Dictionary = {}

func setup(combat_main: CombatMain) -> void:
	_combat_main = combat_main

func get_queue_size() -> int:
	return _queue.size()

func is_queue_busy() -> bool:
	return _processing

func push_items(front: bool, items: Array) -> void:
	assert(_combat_main, "CombatQueueManager.setup(combat_main) must be called before push_items.")
	if items.is_empty():
		return
	var allow_only_when_empty := _is_idle_empty()
	var filtered_items: Array = []
	for item in items:
		var queue_item := item as CombatQueueItem
		if queue_item and queue_item.only_when_empty and !allow_only_when_empty:
			continue
		filtered_items.append(item)
	if filtered_items.is_empty():
		return
	var front_group := _resolve_front_group(filtered_items)
	if !front_group.is_empty():
		var insert_index := _front_group_insert_index(front_group)
		for item in filtered_items:
			_queue.insert(insert_index, item)
			insert_index += 1
	elif front:
		for i in range(filtered_items.size() - 1, -1, -1):
			_queue.push_front(filtered_items[i])
	else:
		_queue.append_array(filtered_items)
	_ensure_draining()

func push_request(request) -> void:
	if !request:
		return
	if !request.callback.is_valid():
		return
	if request.only_when_empty and !_is_idle_empty():
		return
	if !request.unique_id.is_empty():
		if _queued_unique_ids.has(request.unique_id):
			return
		_queued_unique_ids[request.unique_id] = true
	var item := CombatQueueItem.new()
	item.callback = request.callback
	item.finish_callback = request.finish_callback
	item.unique_id = request.unique_id
	item.only_when_empty = request.only_when_empty
	item.front_group = request.front_group
	push_items(request.front, [item])

func has_request_by_unique_id(unique_id: String) -> bool:
	return _queued_unique_ids.has(unique_id)

func _ensure_draining() -> void:
	if _processing:
		return
	_drain_queue()

func _is_idle_empty() -> bool:
	return !_processing and _queue.is_empty()

func _resolve_front_group(items: Array) -> String:
	var front_group := ""
	for item in items:
		var queue_item := item as CombatQueueItem
		assert(queue_item, "All items in one push must be CombatQueueItem.")
		if front_group.is_empty():
			front_group = queue_item.front_group
			continue
		assert(
			front_group == queue_item.front_group,
			"All front-grouped items in one push must share the same front_group."
		)
	return front_group

func _front_group_insert_index(front_group: String) -> int:
	var index := _queue.size() - 1
	while index >= 0:
		var queue_item := _queue[index] as CombatQueueItem
		assert(queue_item, "All items in the queue must be CombatQueueItem.")
		if queue_item.front_group == front_group:
			index += 1
			break
		if index == 0:
			break
		index -= 1
	return index

func _drain_queue() -> void:
	_processing = true
	while not _queue.is_empty():
		var item := _queue.pop_front() as CombatQueueItem
		await _dispatch(item)
		if !item.unique_id.is_empty():
			_queued_unique_ids.erase(item.unique_id)
	_processing = false

func _dispatch(item: CombatQueueItem) -> void:
	var cm := _combat_main
	assert(cm, "CombatMain must remain valid while the combat queue drains.")
	assert(item, "Combat queue item should not be null.")
	assert(item.callback.is_valid(), "Combat queue callback should be valid.")
	await item.callback.call(cm)
	if item.finish_callback.is_valid():
		await item.finish_callback.call(cm)

func _set_combat_main(val: CombatMain) -> void:
	_weak_combat_main = weakref(val)

func _get_combat_main() -> CombatMain:
	return _weak_combat_main.get_ref() as CombatMain
