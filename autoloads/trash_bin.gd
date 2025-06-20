extends Node

func _physics_process(_delta: float) -> void:
	Util.remove_all_children(self)
