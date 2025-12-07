class_name RecycleBalls
extends Node2D

const FLYING_DISTANCE_OFFSET := 10
const MIN_SCALE := 0.10
const MAX_SCALE := 0.20
# How much the path dips down/up (the height of the oval)
const Y_VARIATION_RATIO := 0.3 

@onready var sprite: Sprite2D = %Sprite

var _radius_x: float = 20.0
var _radius_y: float = 6.0
var _angle: float = 0.0
# Angular speed in radians per second
var _angular_speed: float = -3.0 

func update_with_plant(plant: Plant) -> void:
	if not is_inside_tree(): return
	
	var sprite_frames: SpriteFrames = plant.plant_sprite.sprite_frames
	var current_animation: StringName = plant.plant_sprite.animation
	var frame_texture: Texture2D = sprite_frames.get_frame_texture(current_animation, 0)
	var image := frame_texture.get_image()
	var used_rect := image.get_used_rect()
	
	var full_width = used_rect.size.x + FLYING_DISTANCE_OFFSET
	_radius_x = full_width / 2.0
	_radius_y = _radius_x * Y_VARIATION_RATIO
	
	# Reset angle to start at front-left or similar?
	# cos(0) = 1 (right), sin(0) = 0 (center y)
	# Let's start at -PI (left)
	_angle = PI

func _physics_process(delta: float) -> void:
	# Update angle
	_angle += _angular_speed * delta
	if _angle > TAU:
		_angle -= TAU
	
	# Parametric Ellipse Equation
	# x = r_x * cos(angle)
	# y = r_y * sin(angle)
	var x = _radius_x * cos(_angle)
	var y = _radius_y * sin(_angle)
	
	sprite.position = Vector2(x, y)
	
	# Determine Front/Back based on Y position (or sin angle)
	# In Godot, Y is positive downwards.
	# sin(angle) > 0 => Y > 0 => Bottom half (Front)
	# sin(angle) < 0 => Y < 0 => Top half (Back)
	
	if sin(_angle) >= 0:
		# Front path
		sprite.z_index = 0
	else:
		# Back path
		sprite.z_index = -1
		
	# Scale based on Y depth (pseudo-3D)
	# Map sin(_angle) from [-1, 1] to [MIN_SCALE, MAX_SCALE]
	# -1 (back) -> MIN
	#  1 (front) -> MAX
	var t = (sin(_angle) + 1.0) / 2.0 # Normalized 0 to 1
	var scale_val = lerp(MIN_SCALE, MAX_SCALE, t)
	sprite.scale = Vector2(scale_val, scale_val)
