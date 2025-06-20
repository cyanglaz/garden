class_name HighlightableSprite
extends Sprite2D

@export var play_animation := false
@export var animation := "scale"

@onready var animation_player: EnterTreeAnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.animation = animation
	animation_player.auto_play = play_animation

func set_outline(enable:bool):
	if enable:
		(material as ShaderMaterial).set_shader_parameter("color", Constants.COLOR_BLUE_3)
		(material as ShaderMaterial).set_shader_parameter("width", 1)
	else:
		(material as ShaderMaterial).set_shader_parameter("color", Color.TRANSPARENT)
		(material as ShaderMaterial).set_shader_parameter("width", 0)
	
func show_white(strength:float):
	(material as ShaderMaterial).set_shader_parameter("flash_color", Constants.COLOR_WHITE)
	(material as ShaderMaterial).set_shader_parameter("flash_modifier", strength)

func set_alpha(alpha:float):
	(material as ShaderMaterial).set_shader_parameter("alpha", alpha)
	
func set_color(color:Color, strength:float = 1):
	(material as ShaderMaterial).set_shader_parameter("flash_color", color)
	(material as ShaderMaterial).set_shader_parameter("flash_modifier", strength)

func stop_animation():
	animation_player.stop()
