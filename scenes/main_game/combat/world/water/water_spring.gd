class_name WaterSpring
extends Node2D

var velocity := 0.0
var force := 0.0
var height := 0.0
var target_height := 0.0

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
