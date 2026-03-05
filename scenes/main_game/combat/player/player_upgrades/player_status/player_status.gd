class_name PlayerStatus
extends PlayerUpgrade

@warning_ignore("unused_private_class_variable")
var status_data:StatusData

func _set_stack(value:int) -> void:
	status_data.stack = value

func _get_stack() -> int:
	return status_data.stack
