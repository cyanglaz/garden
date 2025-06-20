class_name EnterTreeTimer
extends Timer

func _enter_tree() -> void:
	if !is_node_ready():
		return
	start()
