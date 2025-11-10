class_name Weather
extends Node2D

@onready var weather_component_container: WeatherComponentContainer = %WeatherComponentContainer

func _ready() -> void:
	%WeatherComponentSky.queue_free()
	weather_component_container.hide()

func animate_in() -> void:
	weather_component_container.show()
	await weather_component_container.animate_components_in()

func animate_out() -> void:
	await weather_component_container.animate_components_out()
	weather_component_container.hide()
