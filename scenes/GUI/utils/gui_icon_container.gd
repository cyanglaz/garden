@tool
class_name GUIIconContainer
extends Control

@export var texture:Texture2D: set = _set_texture
@export var border_color:Color: set = _set_border_color
@export var interactable := false : set = _set_interactable
@export var focus_border_color:Color

@onready var item_texture: TextureRect = %ItemTexture
@onready var border: NinePatchRect = %Border

var show_level := false

func _ready():
	_set_interactable(interactable)
	pivot_offset = size/2.0

func _set_texture(val:Texture2D):
	texture = val
	item_texture.texture = val

func _set_border_color(val:Color):
	border_color = val
	%Border.self_modulate = val

func _set_interactable(val:bool):
	interactable = val
	if interactable:
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_ALL
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		focus_mode = Control.FOCUS_NONE

func play_enlarge_animation() -> Signal:
	var tween = Util.create_scaled_tween(self)
	tween.tween_property(self, "scale", Vector2.ONE * 1.2, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.play()
	return tween.finished

func play_reset_animation() -> Signal:
	var tween = Util.create_scaled_tween(self)
	tween.tween_property(self, "scale",  Vector2.ONE, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.play()
	return tween.finished

func set_disable():
	self.modulate.a = 0.5
	
func set_enable():
	self.modulate.a = 1.0
	
func highlight():
	%Border.self_modulate = focus_border_color

func dehighlight():
	%Border.self_modulate = border_color
