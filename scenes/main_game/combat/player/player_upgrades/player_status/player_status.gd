class_name PlayerStatus
extends PlayerUpgrade

func _set_stack(value:int) -> void:
	data.stack = value

func _get_stack() -> int:
	return data.stack
