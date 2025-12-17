class_name RecycleBalls
extends Node2D

const FLYING_DISTANCE_OFFSET := 10
const MIN_SCALE := 0.10
const MAX_SCALE := 0.20
const Y_OFFSET := 10.0
# How much the path dips down/up (the height of the oval)
const Y_VARIATION_RATIO := 0.3 
const TILT_ANGLE_DEGREES: float = -10.0

@onready var sprite: Sprite2D = %Sprite

var _radius_x: float = 20.0
var _radius_y: float = 6.0
var _angle: float = 0.0
# Angular speed in radians per second (Negative for CCW: Left->Right at bottom)
var _angular_speed: float = -3.0 
# Progress along the path [0.0, 1.0]
var current_progress: float = 0.0 : set = _set_current_progress

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
	
	# Start at Left side (PI) so we enter the Front path immediately
	# Progress ~ 0.5 (PI is halfway in 2PI, but reversed?)
	# Let's rely on angle logic for start
	_angle = PI

func _physics_process(delta: float) -> void:
	# Update angle
	_angle += _angular_speed * delta
	if _angle > TAU:
		_angle -= TAU
	elif _angle < -TAU:
		_angle += TAU
	
	_update_progress_from_angle()
	_update_position()

func _update_progress_from_angle() -> void:
	current_progress = 1.0 - (fposmod(_angle, TAU) / TAU)

func _update_position() -> void:
	if not is_inside_tree() or not sprite: return
	
	# Parametric Ellipse Equation (local coordinates)
	var local_x = _radius_x * cos(_angle)
	var local_y = _radius_y * sin(_angle)
	
	# Apply Tilt Rotation
	var pos = Vector2(local_x, local_y).rotated(deg_to_rad(TILT_ANGLE_DEGREES))
	sprite.position = pos + Vector2.UP * Y_OFFSET
	
	# Determine Front/Back based on local phase (unrotated Y)
	if sin(_angle) >= 0:
		# Front path
		sprite.z_index = 0
	else:
		# Back path
		sprite.z_index = -1
		
	# Scale based on Y depth (pseudo-3D)
	var t = (sin(_angle) + 1.0) / 2.0 
	var scale_val = lerp(MIN_SCALE, MAX_SCALE, t)
	sprite.scale = Vector2(scale_val, scale_val)

func _set_current_progress(value: float) -> void:
	print("set_current_progress: ", value)
	if value < 0.0:
		value = 1.0 - abs(value)
	current_progress = value # Allow wrapping? Or clamp? Assuming standard 0-1
	# Map progress back to angle
	# progress = 1.0 - (angle / TAU)
	# angle = (1.0 - progress) * TAU
	_angle = (1.0 - current_progress) * TAU
	_update_position()
