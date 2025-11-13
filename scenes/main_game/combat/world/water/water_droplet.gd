class_name WaterDroplet
extends Node2D

const TOUCH_DESTROY_DELAY := 0.1
const MAX_TIME := 2.0

@onready var area_2d: Area2D = %Area2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var initial_up_velocity := 0.0
var gravity := 100.0
var rotation_velocity := 0.0
var initial_angle := 0.0
var velocity := Vector2.ZERO
var texture: Texture2D = null: set = _set_texture

func _ready() -> void:
	area_2d.area_entered.connect(_on_area_entered)
	_set_texture(texture)
	velocity = (Vector2.UP * initial_up_velocity).rotated(deg_to_rad(initial_angle))
	get_tree().create_timer(MAX_TIME).timeout.connect(func(): 
		queue_free()
	)

func _physics_process(delta: float) -> void:
	rotation_degrees += rotation_velocity * delta
	velocity += Vector2.DOWN * gravity
	position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
	assert(area.get_parent() is WaterSpring)
	if velocity.y > 0:
		collision_shape_2d.set_deferred("disabled", true)
		get_tree().create_timer(TOUCH_DESTROY_DELAY).timeout.connect(func():
			queue_free()	
		)

func _set_texture(value: Texture2D) -> void:
	texture = value
	if sprite_2d:
		sprite_2d.texture = value
