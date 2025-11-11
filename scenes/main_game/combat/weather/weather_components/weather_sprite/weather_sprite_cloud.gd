class_name WeatherSpriteCloud
extends WeatherSprite

const MAX_SHAPE_TYPE := 3

enum ColorType {
	WHITE,
	GRAY,
}

@export var color_type: ColorType = ColorType.WHITE

func _ready() -> void:
	super._ready()
	var shape_type := randi() % MAX_SHAPE_TYPE
	var color_string := "white"
	match color_type:
		ColorType.WHITE:
			color_string = "white"
		ColorType.GRAY:
			color_string = "gray"
	color_string = color_string + "_" + str(shape_type)
	_animated_sprite_2d.play("idle_" + color_string)
