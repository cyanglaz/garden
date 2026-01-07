class_name SunScorch
extends Node2D

const SKY_HEIGHT := -100.0
const BEAM_COLOR := Constants.COLOR_WHITE
const BEAM_WIDTH := 16.0
const BEAM_ANIMATION_INTERVAL := 0.1

@onready var beam_line: Line2D = %BeamLine

func execute_scorch(target_pos: Vector2, is_blocked: bool):
	global_position = target_pos
	
	# === PHASE 1: TELEGRAPH (The Warning) ===
	#telegraph_spot.visible = true
	#telegraph_spot.modulate = Color(1, 0.2, 0, 0) # Start transparent Red
	
	#var tween = create_tween()
	
	# Pulse the warning spot on the ground
	#tween.tween_property(telegraph_spot, "modulate:a", 0.8, 0.5).set_trans(Tween.TRANS_SINE)
	#tween.tween_property(telegraph_spot, "scale", Vector2(1.2, 1.2), 0.5)
	
	# Wait...
	#await tween.finished
	#telegraph_spot.visible = false
	
	# === PHASE 2: THE STRIKE (Snap Down) ===
	# Configure impact particles based on target
	#if is_blocked:
	#	# Hitting Player (Smoke/Ash)
	#	impact_particles.process_material.color = Color.DARK_GRAY
	#	impact_particles.amount = 30 # More debris
	#else:
	#	# Hitting Plant (Steam)
	#	impact_particles.process_material.color = Color.WHITE
	#	impact_particles.amount = 15
		
	#impact_particles.emitting = true
	
	# Animate the Beam Width (Snap Effect)
	# Start invisible
	var start_point = Vector2(0, SKY_HEIGHT)
	beam_line.add_point(Vector2.ZERO)
	beam_line.add_point(start_point)

	beam_line.width = 0 
	beam_line.visible = true
	
	var strike_tween = create_tween()
	
	# A. SNAP OPEN (Violent expansion)
	strike_tween.tween_property(beam_line, "width", BEAM_WIDTH, BEAM_ANIMATION_INTERVAL).set_trans(Tween.TRANS_BOUNCE)
	
	# B. HOLD & JITTER (Burning)
	# We can fake a jitter by tweening the width slightly up and down
	strike_tween.tween_property(beam_line, "width", BEAM_WIDTH-5, BEAM_ANIMATION_INTERVAL)
	strike_tween.tween_property(beam_line, "width", BEAM_WIDTH-2, BEAM_ANIMATION_INTERVAL)
	
	# C. FADE OUT
	strike_tween.tween_property(beam_line, "width", 0, 0.2)
	
	# D. CLEANUP
	strike_tween.tween_callback(queue_free)

	await Util.create_scaled_timer(BEAM_ANIMATION_INTERVAL * 3).timeout
