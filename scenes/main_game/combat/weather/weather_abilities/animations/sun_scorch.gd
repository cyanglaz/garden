class_name SunScorch
extends WeatherAbilityAnimation

const SKY_HEIGHT := -100.0
const BEAM_COLOR := Constants.COLOR_RED1
const BEAM_ALPHA := 0.3
const BEAM_WIDTH := 6
const BEAM_ANIMATION_INTERVAL := 0.1

@onready var beam_line: Line2D = %BeamLine
@onready var impact_particle: GPUParticles2D = %ImpactParticle
@onready var beam_sound: AudioStreamPlayer2D = %BeamSound

func start(_icon_position: Vector2, target_pos: Vector2, _is_blocked: bool):
	global_position = target_pos

	impact_particle.one_shot = true
	
	# Animate the Beam Width (Snap Effect)
	# Start invisible
	var start_point = Vector2(0, SKY_HEIGHT)
	beam_line.add_point(Vector2.ZERO)
	beam_line.add_point(start_point)

	beam_line.width = 0 
	beam_line.visible = true
	beam_line.default_color = BEAM_COLOR
	beam_line.default_color.a = BEAM_ALPHA
	
	var strike_tween = Util.create_scaled_tween(self)
	strike_tween.set_parallel(true)
	
	# A. SNAP OPEN (Violent expansion)
	strike_tween.tween_property(beam_line, "width", BEAM_WIDTH, BEAM_ANIMATION_INTERVAL).set_trans(Tween.TRANS_BOUNCE)
	
	# B. HOLD & JITTER (Burning)
	# We can fake a jitter by tweening the width slightly up and down
	strike_tween.tween_property(beam_line, "width", BEAM_WIDTH-5, BEAM_ANIMATION_INTERVAL).set_delay(BEAM_ANIMATION_INTERVAL)
	strike_tween.tween_property(beam_line, "width", BEAM_WIDTH-2, BEAM_ANIMATION_INTERVAL).set_delay(BEAM_ANIMATION_INTERVAL*2)
	
	# C. FADE OUT
	strike_tween.tween_property(beam_line, "width", 0, 0.2).set_delay(BEAM_ANIMATION_INTERVAL*3)
	
	# D. Impact Particle
	await Util.create_scaled_timer(BEAM_ANIMATION_INTERVAL*2).timeout
	impact_particle.restart()
	beam_sound.play()
	await Util.create_scaled_timer(impact_particle.lifetime).timeout

	
