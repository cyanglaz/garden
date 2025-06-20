extends Node2D

@onready var node_2d: Node2D = $Node2D

#
#var can_shoot = true
#var trail
#var bullet
#@onready var smoke_trail: SmokeTrail = $SmokeTrail
#
#func _process(delta):d
	#if Input.is_action_pressed("shoot"):
		#smoke_trail.add_trail_point(get_global_mouse_position())
	#
	##if Input.is_action_pressed("shoot") and can_shoot:
		##can_shoot = false
		##$can_shoot.start()
		##bullet = Bullet.instantiate()
		##bullet.target_global_position = Vector2.RIGHT.rotated(randf_range(-0.05, 0.05))
		##bullet.position = get_global_mouse_position() + Vector2(0,50)
		##trail:Smoke = Smoketrail.instantiate()
		##trail.
		##bullet.add_child(trail)
		##add_child(bullet)
		#
#
#func _on_can_shoot_timeout():
	#can_shoot = true

func _input(event: InputEvent) -> void:
	if event.is_action_released("shoot"):
		var bullet = Bullet.instantiate()
		bullet.target = node_2d
		bullet.target_global_position = Vector2.RIGHT.rotated(randf_range(-0.05, 0.05))
		bullet.position = get_global_mouse_position() + Vector2(0,50)
		add_child(bullet)
