class_name LightningStrikeAnimation
extends WeatherAbilityAnimation

const STARTING_HEIGHT := 100

@onready var main_bolt_template: Line2D = %MainBolt
@onready var impact_sparks: GPUParticles2D = %ImpactSparks
@onready var scorch_mark: Sprite2D = %ScorchMark
@onready var audio_stream_player_2d: AudioStreamPlayer2D = %AudioStreamPlayer2D

# Settings
var sway = 5.0 # How wide the bolt can wander
var jaggedness = 0.5 # Chaos factor (higher = more jagged)
var branch_probability = 1.0 # Chance to spawn a fork

func _ready() -> void:
	#start(Vector2.ZERO, Vector2(0, 0), false)
	impact_sparks.one_shot = true
	#scorch_mark.modulate.a = 0.0

func start(_icon_position:Vector2, target_global_pos: Vector2, _is_blocked:bool) -> void:
	global_position = target_global_pos
	audio_stream_player_2d.play()
	# 1. Calculate Global Start and End points
	# Start is 600px straight up from the target
	var start_local = Vector2(0, -STARTING_HEIGHT)
	var end_local = Vector2.ZERO
	
	# 2. Convert these Global points to Local points
	# This fixes the "Invisible Line" issue by ensuring we draw relative to THIS node
	
	# 3. Position the sparks at the local impact point
	impact_sparks.emitting = true
	
	# 4. Generate the Main Bolt using Local Points
	_create_lightning_branch(start_local, end_local, main_bolt_template.width)
	
	# Hide the template
	main_bolt_template.visible = false
	
	scorch_mark.modulate.a = 0.8
	scorch_mark.scale = Vector2(0.1, 0.1) # Start tiny
	
	var tween = create_tween()
	
	# 2. Expand quickly (Shockwave feel)
	tween.tween_property(scorch_mark, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_BACK)
	tween.tween_property(scorch_mark, "modulate:a", 0.0, 0.3).set_delay(0.2)
	# Cleanup
	await get_tree().create_timer(1.0).timeout

func _create_lightning_branch(start_pos: Vector2, end_pos: Vector2, thickness: float):
	var new_line = main_bolt_template.duplicate()
	add_child(new_line)
	new_line.visible = true
	new_line.width = thickness
	
	# Generate Fractal Points
	var points = _generate_fractal_points(start_pos, end_pos, sway)
	new_line.points = points
	
	_animate_bolt(new_line)
	
	# Create Sub-branches
	if thickness > 4.0:
		for i in range(1, points.size() - 1):
			if randf() < branch_probability:
				var branch_start = points[i]
				var branch_end = branch_start + Vector2(randf_range(-100, 100), randf_range(50, 150))
				_create_lightning_branch(branch_start, branch_end, thickness)

func _generate_fractal_points(start_pos: Vector2, end_pos: Vector2, current_sway: float) -> Array:
	var points = [start_pos, end_pos]
	var iterations = 5 
	
	for i in range(iterations):
		var new_points = []
		for j in range(points.size() - 1):
			var p1 = points[j]
			var p2 = points[j+1]
			
			var mid = (p1 + p2) / 2
			var direction = (p2 - p1).normalized()
			var normal = Vector2(-direction.y, direction.x)
			var offset = normal * randf_range(-current_sway, current_sway)
			
			new_points.append(p1)
			new_points.append(mid + offset)
		
		new_points.append(points.back())
		points = new_points
		current_sway *= jaggedness 
		
	return points

func _animate_bolt(line_node: Line2D):
	var tween = create_tween()
	# Rapid flicker
	tween.tween_property(line_node, "modulate:a", 1.0, 0.05)
	tween.tween_property(line_node, "modulate:a", 0.3, 0.05)
	tween.tween_property(line_node, "modulate:a", 1.0, 0.05)
	# Fade out
	tween.tween_property(line_node, "modulate:a", 0.0, 0.25)
	tween.tween_callback(line_node.queue_free)
