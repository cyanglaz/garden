class_name Weather
extends Node2D

@onready var weather_sprite_container: WeatherSpriteContainer = %WeatherSpriteContainer
@onready var weather_particle_container: WeatherParticleContainer = %WeatherParticleContainer

func _ready() -> void:
	%WeatherSky.queue_free()
	weather_sprite_container.hide()
	weather_particle_container.hide()

func animate_in() -> void:
	weather_sprite_container.show()
	await weather_sprite_container.animate_sprites_in()
	weather_particle_container.show()
	weather_particle_container.start()

func animate_out() -> void:
	weather_particle_container.stop()
	await weather_sprite_container.animate_sprites_out()
	weather_sprite_container.hide()

func stop() -> void:
	weather_particle_container.stop_sounds()
	#weather_sprite_container.hide()
