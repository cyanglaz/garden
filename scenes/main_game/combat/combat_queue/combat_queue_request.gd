class_name CombatQueueRequest
extends RefCounted

var front: bool = false
var unique_id: String = ""
var callback: Callable
var finish_callback: Callable
var only_when_empty: bool = false
