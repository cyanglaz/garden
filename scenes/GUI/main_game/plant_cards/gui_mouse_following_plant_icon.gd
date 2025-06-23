class_name GUIMouseFollowingPlantIcon
extends GUIPlantIcon

var follow_mouse := false

func _physics_process(_delta: float) -> void:
	if follow_mouse && visible:
		global_position = get_global_mouse_position() - size/2
