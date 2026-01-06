class_name SolarBeam
extends Node2D

const BEAM_WIDTH := 8.0
const DURATION := 0.5
const SKY_HEIGHT := -100.0
const CHARGING_TIME := 0.2
const CHARGING_COLOR_ALPHA := 0.5
const BEAM_COLOR := Constants.COLOR_WHITE
const CHARGING_COLOR := Constants.COLOR_ORANGE1
const WARNING_LINE_WIDTH := 1.0

@onready var beam_line: Line2D = %BeamLine
@onready var line_particle: GPUParticles2D = %LineParticle

func cast_beam(target_position:Vector2, blocked_by_player:bool) -> void:
	# 1. Determine Start and End points
	# The beam always starts directly above the target in the "sky"
	var start_point = Vector2(0, SKY_HEIGHT)
	
	var end_point = Vector2.ZERO
	beam_line.clear_points()
	beam_line.add_point(start_point)
	beam_line.add_point(end_point)
	
	global_position = target_position
	line_particle.global_position = target_position + start_point/2
	line_particle.process_material.emission_box_extents = Vector3(BEAM_WIDTH*0.8, start_point.y/2, 1)
	line_particle.one_shot = true

	# 1. Show a very thin "warning line" first
	beam_line.width = WARNING_LINE_WIDTH 
	var charging_color = CHARGING_COLOR
	charging_color.a = 0.5
	beam_line.default_color = charging_color
	# 2. Wait for a moment
	await Util.create_scaled_timer(CHARGING_TIME).timeout
	
	beam_line.default_color = BEAM_COLOR
	# 3. Animate the Blast
	var tween = create_tween()
	
	# Phase A: Expand Beam (Attack)
	tween.tween_property(beam_line, "width", BEAM_WIDTH, 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_callback(line_particle.restart) # Spark effects
	
	# Phase B: Hold briefly
	tween.tween_interval(0.2)
	
	# Phase C: Shrink Beam (Fade out)
	tween.tween_property(beam_line, "width", 0.0, 0.2)
	
	# Phase D: Cleanup
	await tween.finished
	line_particle.finished.connect(func(): queue_free())
