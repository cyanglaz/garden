class_name Pest
extends Node2D

@export var moving_area_size: Vector2 = Vector2(0, 0)
@export var min_speed: float = 20.0
@export var max_speed: float = 50.0

var _curve: Curve2D
var _path_progress: float = 0.0
var _current_speed: float
var _target_speed: float

func _ready() -> void:
	assert(moving_area_size.x > 0 and moving_area_size.y > 0, "Moving area size must be greater than 0")
	_generate_path()
	_current_speed = randf_range(min_speed, max_speed)
	_pick_new_speed()

func _physics_process(delta: float) -> void:
	if not _curve:
		return
		
	# Randomly change speed
	if randf() < 0.02:
		_pick_new_speed()
	
	# Smoothly change speed
	_current_speed = move_toward(_current_speed, _target_speed, delta)
	
	# Move along path
	_path_progress += _current_speed * delta
	var max_len = _curve.get_baked_length()
	
	# Wrap around
	if _path_progress >= max_len:
		_path_progress -= max_len
	
	# Update position
	position = _curve.sample_baked(_path_progress)
	#print(position)
	
	# Update rotation (look ahead)
	var look_ahead_dist = 5.0 
	var look_ahead_progress = _path_progress + look_ahead_dist
	if look_ahead_progress >= max_len:
		look_ahead_progress -= max_len
		
	var next_pos = _curve.sample_baked(look_ahead_progress)
	if position.distance_squared_to(next_pos) > 0.001:
		rotation = (next_pos - position).angle()

func _generate_path() -> void:
	_curve = Curve2D.new()
	_curve.bake_interval = 5.0
	
	# Increase number of points for more complex paths
	var num_points = randi_range(7, 10)
	var points: Array[Vector2] = []
	
	# Generate random points inside the area (Cartesian, not Polar)
	# This allows the path to criss-cross and not look like a circle
	for i in range(num_points):
		# Try to find a point that isn't too close to the previous one
		var attempts = 0
		var p = Vector2.ZERO
		var valid = false
		
		while not valid and attempts < 10:
			var x = randf_range(-moving_area_size.x/2, moving_area_size.x/2)
			var y = randf_range(-moving_area_size.y/2, moving_area_size.y/2)
			p = Vector2(x, y)
			
			if points.is_empty():
				valid = true
			else:
				# Ensure minimum distance from previous point to prevent tight knots
				if p.distance_squared_to(points.back()) > 400: # 20*20
					valid = true
			attempts += 1
			
		points.append(p)
		#print(p)
	
	# Calculate controls and add points (Catmull-Rom splines)
	for i in range(num_points):
		var p_prev = points[(i - 1 + num_points) % num_points]
		var p_curr = points[i]
		var p_next = points[(i + 1) % num_points]
		
		# Tangent parallel to vector from prev to next
		var tangent = (p_next - p_prev).normalized()
		# Tension factor: 0.2 to 0.3 is usually good for smooth but not too loopy
		var dist = (p_next - p_prev).length() * 0.2 
		
		_curve.add_point(p_curr, -tangent * dist, tangent * dist)
	
	# Close the loop smoothly
	var p_first = points[0]
	var p_last = points[num_points - 1]
	var p_second = points[1]
	
	var last_tangent = (p_second - p_last).normalized()
	var last_dist = (p_second - p_last).length() * 0.2
	
	_curve.add_point(p_first, -last_tangent * last_dist, last_tangent * last_dist)

func _pick_new_speed() -> void:
	_target_speed = randf_range(min_speed, max_speed)
