class_name CombatQueueItem
extends RefCounted

var unique_id: String = ""
var callback: Callable
var finish_callback: Callable
var only_when_empty: bool = false
