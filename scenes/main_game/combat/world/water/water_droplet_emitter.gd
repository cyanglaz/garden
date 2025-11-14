class_name WaterDropletEmitter
extends Node2D

const DROPLET_SCENE := preload("res://scenes/main_game/combat/world/water/water_droplet.tscn")

@export var max_initial_up_velocity := 85.0
@export var min_initial_up_velocity := 80.0
@export var gravity := 3
@export var min_rotation_velocity := -90.0
@export var max_rotation_velocity := 90.0
@export var number_of_droplets := 8
@export var droplet_spread_degrees := 25.0
@export var droplet_position_range := 30.0
@export var droplet_texture: Texture2D = null

func _ready() -> void:
	pass

func emit_droplets() -> void:
	for i in number_of_droplets:
		var droplet := DROPLET_SCENE.instantiate()
		if droplet_texture:
			droplet.texture = droplet_texture
		droplet.initial_up_velocity = randf_range(min_initial_up_velocity, max_initial_up_velocity)
		droplet.gravity = gravity
		droplet.rotation_velocity = randf_range(min_rotation_velocity, max_rotation_velocity)
		droplet.position = Vector2(randf_range(-droplet_position_range/2, droplet_position_range/2), 0)
		droplet.initial_angle = randf_range(-droplet_spread_degrees, droplet_spread_degrees)
		add_child(droplet)
