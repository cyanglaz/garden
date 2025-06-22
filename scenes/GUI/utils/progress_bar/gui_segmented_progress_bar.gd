@tool
class_name GUISegmentedProgressBar
extends HBoxContainer

@export var max_value: int = 100: set = _set_max_value
@export var current_value: int = 0: set = _set_current_value
@export var segment_color: Color = Constants.COLOR_BLUE_2
@export var segment_off_color: Color = Constants.COLOR_GRAY4
@export var border_color:Color = Constants.COLOR_GRAY6 : set = _set_border_color
@export var icon_texture:Texture2D: set = _set_icon_texture

@onready var _background: ColorRect = %Background
@onready var _border: NinePatchRect = %Border
@onready var _h_box_container: HBoxContainer = %HBoxContainer
@onready var _icon: TextureRect = %Icon

func _ready() -> void:
	#assert(((size.x as int) - 1) % max_value == 0, "segemented bar has to be equally devided to have the segenemts to be the same size")
	_set_border_color(border_color)
	_set_max_value(max_value)
	_set_current_value(current_value)
	_set_icon_texture(icon_texture)

func _set_border_color(val: Color) -> void:
	border_color = val
	if _border:
		_border.self_modulate = border_color
		_background.self_modulate = border_color

func _set_max_value(val: int) -> void:
	max_value = val
	if _h_box_container:
		Util.remove_all_children(_h_box_container)
		for i in range(max_value):
			var segment:= ColorRect.new()
			_h_box_container.add_child(segment)
			segment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			segment.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _set_current_value(val: int) -> void:
	current_value = val
	if _h_box_container:
		for i in range(max_value):
			var segment:= _h_box_container.get_child(i)
			if i < current_value:
				segment.color = segment_color
			else:
				segment.color = segment_off_color

func _set_icon_texture(val: Texture2D) -> void:
	icon_texture = val
	if _icon:
		_icon.texture = icon_texture
		if icon_texture:
			_icon.visible = true
			_icon.custom_minimum_size.x = size.y
		else:
			_icon.visible = false
