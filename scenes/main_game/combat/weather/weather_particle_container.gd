class_name WeatherParticleContainer
extends Node2D

var _particles:Array[WeatherParticles]

func _ready() -> void:
	for child in get_children():
		assert(child is WeatherParticles, "Child is not a WeatherParticles")
		_particles.append(child)

func start() -> void:
	for particle in _particles:
		particle.start()

func stop() -> void:
	stop_sounds()
	for particle in _particles:
		particle.stop()

func stop_sounds() -> void:
	for particle in _particles:
		particle.fade_out_sounds()
