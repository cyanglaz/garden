class_name Weather
extends Node2D

@onready var weather_sprite_container: WeatherSpriteContainer = %WeatherSpriteContainer

func _ready() -> void:
	%WeatherSky.queue_free()
	weather_sprite_container.hide()

func animate_in() -> void:
	weather_sprite_container.show()
	await weather_sprite_container.animate_sprites_in()

func animate_out() -> void:
	await weather_sprite_container.animate_sprites_out()
	weather_sprite_container.hide()
