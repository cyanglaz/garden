class_name CombatQueueCallableItem
extends RefCounted

## Invoked as `await callback.call(combat_main)`; may `await` internally.
var callback: Callable

func _init(p_callback: Callable = Callable()) -> void:
	callback = p_callback
