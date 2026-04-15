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
	if front:
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
	push_items(request.front, [item])

func clear_queue() -> void:
	_queue.clear()
	_queued_unique_ids.clear()
	_processing = false

func _ensure_draining() -> void:
	if _processing:
		return
	_drain_queue()

func _is_idle_empty() -> bool:
	return !_processing and _queue.is_empty()

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
