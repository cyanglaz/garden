class_name CombatQueueManager
extends RefCounted

const _CombatQueueActionsItem := preload("res://scenes/main_game/combat/combat_queue/combat_queue_actions_item.gd")
const _CombatQueueCallableItem := preload("res://scenes/main_game/combat/combat_queue/combat_queue_callable_item.gd")

## Serial async queue for combat steps. Add as a child of [CombatMain] and call [method setup]
## before [method push_items].

var _combat_main: CombatMain:
	set = _set_combat_main,
	get = _get_combat_main

var _weak_combat_main: WeakRef = weakref(null)
var _queue: Array = []
var _processing: bool = false
var _actions_applier: ActionsApplier = ActionsApplier.new()

func setup(combat_main: CombatMain) -> void:
	_combat_main = combat_main

func get_queue_size() -> int:
	return _queue.size()


func is_queue_busy() -> bool:
	return _processing

## If [param front] is true, the batch is inserted at the head preserving internal order
## (first in [param items] runs before second). If false, appends in order to the tail.
## Items must be [CombatQueueActionsItem] or [CombatQueueCallableItem] (or future subclasses of [CombatQueueItem]).
func push_items(front: bool, items: Array) -> void:
	if !_combat_main:
		push_error("CombatQueueManager.setup(combat_main) must be called before push_items.")
		return
	if items.is_empty():
		return
	if front:
		for i in range(items.size() - 1, -1, -1):
			_queue.push_front(items[i])
	else:
		_queue.append_array(items)
	_ensure_draining()

func _ensure_draining() -> void:
	if _processing:
		return
	_drain_queue()

func _drain_queue() -> void:
	_processing = true
	while not _queue.is_empty():
		var item: Variant = _queue.pop_front()
		await _dispatch(item)
	_processing = false

func _dispatch(item: Variant) -> void:
	var cm := _combat_main
	if !cm:
		push_warning("Combat queue item skipped: CombatMain is no longer valid.")
		return
	if is_instance_of(item, _CombatQueueActionsItem):
		await _actions_applier.apply_actions(
			item.actions,
			cm,
			item.tool_card,
			cm.gui.gui_tool_card_container,
		)
	elif is_instance_of(item, _CombatQueueCallableItem):
		await item.callback.call(cm)
	else:
		push_error("Unknown combat queue item type: %s" % item)

func _set_combat_main(val: CombatMain) -> void:
	_weak_combat_main = weakref(val)

func _get_combat_main() -> CombatMain:
	return _weak_combat_main.get_ref() as CombatMain
