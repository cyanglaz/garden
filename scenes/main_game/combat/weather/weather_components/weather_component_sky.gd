class_name WeatherComponentSky
extends Polygon2D

@export var sky_color:Color = Constants.COLOR_BLUE_4

func _ready() -> void:
	color = sky_color
