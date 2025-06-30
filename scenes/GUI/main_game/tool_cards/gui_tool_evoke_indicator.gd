class_name GUIToolEvokeIndicator
extends Control

var follow_mouse:bool = true
var from_position:Vector2 = Vector2.ZERO: set = _set_from_position
var to_position:Vector2 = Vector2.ZERO: set = _set_to_position

@onready var _line: NinePatchRect = $Line

func _ready() -> void:
	pass

func _physics_process(_delta:float) -> void:
	if follow_mouse:
		to_position = get_global_mouse_position()

func _update() -> void:
	global_position = from_position
	var length = from_position.distance_to(to_position)
	var angle = from_position.angle_to_point(to_position)
	_line.size.x = length
	rotation = angle

func _set_to_position(val:Vector2) -> void:
	to_position = val
	_update()

func _set_from_position(val:Vector2) -> void:
	from_position = val
	_update()
