class_name WaterSpring
extends Node2D

const COLLISION_DISABLED_TIME := 0.5

signal area_entered(area: Area2D)

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var area_2d: Area2D = %Area2D

var velocity := 0.0
var force := 0.0
var height := 0.0
var target_height := 0.0
var motion_factor = 0.02

func _ready() -> void:
	area_2d.area_entered.connect(_on_area_entered)
	
func initialize() -> void:
	height = position.y
	target_height = height
	velocity = 0

func water_update(sprint_constant: float, dampening:float) -> void:
	# This function applies the hooke's law force to the spring!
	# Called each frame

	height = position.y
	var x = height - target_height
	var loss = -dampening * velocity
	force = -sprint_constant * x + loss
	velocity += force
	position.y += velocity

func set_collision_width(w:float) -> void: 
	var shape_size := (collision_shape_2d.shape as RectangleShape2D).size
	collision_shape_2d.shape.size = Vector2(w, shape_size.y)

func _on_area_entered(_area: Area2D) -> void:
	area_entered.emit(area_2d)
