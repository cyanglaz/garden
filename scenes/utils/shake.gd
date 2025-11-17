class_name Shake
extends Node

@onready var _parent = get_parent()

const SHAKE_AMPLITUDE := Vector2(5, 5)
const NOISE_SPEED := 1
const TRAUMA_POWER := 2

var _priority := 0
# Pixels of the shake
var _amplitude := Vector2.ZERO
var _rotation := 0.0
var _trauma := 0.0
var _noise_y = 0
var _decay := 0.5
var _noise = FastNoiseLite.new()

func start(trauma:float = 0.6, amplitude:Vector2 = SHAKE_AMPLITUDE, rotation:float = 0.05, decay:float = 1, priority := 0):
	assert(trauma > 0.0 && trauma <= 1.0)
	Input.start_joy_vibration(1, 1, 1, 1)
	# Smaller random seed to prevent stack overflow
	_noise.seed = randi_range(0, 99999)
	if priority >= _priority:
		_amplitude = amplitude
		_decay = decay
		_add_trauma(trauma)
		_rotation = rotation
		#_new_shake()

func _ready() -> void:
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.fractal_gain = 50.0

func _physics_process(delta: float) -> void:
	if _trauma > 0:
		_trauma = max(_trauma - _decay * delta, 0)
		_shake()

func _add_trauma(amount:float):
	_trauma = min(_trauma + amount, 0.7)
	
func _shake():
	_noise_y += NOISE_SPEED
	var amount = pow(_trauma, TRAUMA_POWER)
	_parent.position.x = _amplitude.x * amount * _noise.get_noise_2d(_noise.seed, _noise_y)
	_parent.position.y= _amplitude.y * amount * _noise.get_noise_2d(_noise.seed*2, _noise_y)
	_parent.rotation = _rotation * amount * _noise.get_noise_2d(_noise.seed*3, _noise_y)
	print(_parent.position.x)
	print(_parent.position.y)
