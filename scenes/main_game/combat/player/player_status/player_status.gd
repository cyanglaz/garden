class_name PlayerStatus
extends Node2D

@warning_ignore("unused_private_class_variable")
var status_data:StatusData
var stack:int:set = _set_stack, get = _get_stack

func has_prevent_movement_hook() -> bool:
	return _has_prevent_movement_hook()

func toggle_ui_buttons(on:bool) -> void:
	_toggle_ui_buttons(on)

#region for override

func _has_prevent_movement_hook() -> bool:
	return false

func _toggle_ui_buttons(_on:bool) -> void:
	pass

#endregion

func _set_stack(value:int) -> void:
	status_data.stack = value

func _get_stack() -> int:
	return status_data.stack
