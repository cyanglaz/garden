class_name TrinketGlobalScript
extends RefCounted

var trinket_data:TrinketData

func has_on_collect_hook() -> bool:
	return _has_on_collect_hook()

func handle_on_collect_hook() -> void:
	pass

#region For Subclasses

func _has_on_collect_hook() -> bool:
	return false

func _handle_on_collect_hook() -> void:
	pass