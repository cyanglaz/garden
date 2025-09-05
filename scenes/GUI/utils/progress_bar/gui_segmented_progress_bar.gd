@tool
class_name GUISegmentedProgressBar
extends HBoxContainer

@export var max_value: int = 100: set = _set_max_value
@export var current_value: int = 0: set = _set_current_value
@export var segment_color: Color = Constants.COLOR_BLUE_2
@export var segment_off_color: Color = Constants.COLOR_GRAY3
@export var border_color:Color = Constants.COLOR_GRAY6 : set = _set_border_color
@export var background_color:Color = Constants.COLOR_GRAY4: set = _set_background_color
@export var icon_texture:Texture2D: set = _set_icon_texture
@export var icon_size:Vector2: set = _set_icon_size
@export var segment_separation:float = 1.0

@onready var _background: ColorRect = %Background
@onready var _border: NinePatchRect = %Border
@onready var _segment_container: Control = %SegmentContainer
@onready var _icon: TextureRect = %Icon
@onready var _margin_container: MarginContainer = %MarginContainer

var _weak_resource_point:WeakRef = weakref(null)

func _ready() -> void:
	#assert(((size.x as int) - 1) % max_value == 0, "segemented bar has to be equally devided to have the segenemts to be the same size")
	_set_border_color(border_color)
	_set_background_color(background_color)
	_set_icon_size(icon_size)
	_set_max_value(max_value)
	_set_current_value(current_value)
	_set_icon_texture(icon_texture)
	_adjust_segment_size.call_deferred()

func bind_with_resource_point(resource_point:ResourcePoint) -> void:
	max_value = resource_point.max_value
	current_value = resource_point.value
	_weak_resource_point = weakref(resource_point)
	resource_point.value_update.connect(func(): _set_current_value(resource_point.value))
	resource_point.max_value_update.connect(func(): _set_max_value(resource_point.max_value))

func _adjust_segment_size() -> void:
	if !_margin_container:
		return
	# var segment_width: float = _h_box_container.get_child(0).size.x
	# var total_width:float = _icon.size.x + get_theme_constant("separation") + _margin_container.get_theme_constant("margin_left") + _margin_container.get_theme_constant("margin_right") + max_value * segment_width + _h_box_container.get_theme_constant("separation") * (max_value - 1)
	var icon_x:float = _icon.size.x if _icon else 0.0
	var total_none_segment_width :float = icon_x + get_theme_constant("separation") + _margin_container.get_theme_constant("margin_left") + _margin_container.get_theme_constant("margin_right") + segment_separation * (max_value - 1)
	var total_segment_width:float = size.x - total_none_segment_width
	var segment_width:float = total_segment_width / max_value
	for i in range(max_value):
		var segment:= _segment_container.get_child(i)
		segment.size.x = segment_width
		segment.size.y = _segment_container.size.y
		segment.position.x = i * (segment_width + segment_separation)

func _set_border_color(val: Color) -> void:
	border_color = val
	if _border:
		_border.self_modulate = border_color
	if _background:
		if max_value == 0:
			_background.self_modulate = background_color
		else:
			_background.self_modulate = border_color
	

func _set_background_color(val:Color) -> void:
	background_color = val
	if _background:
		if max_value == 0:
			_background.self_modulate = background_color
		else:
			_background.self_modulate = border_color
	
func _set_max_value(val: int) -> void:
	max_value = val
	if _segment_container:
		Util.remove_all_children(_segment_container)
		for i in range(max_value):
			var segment:= ColorRect.new()
			_segment_container.add_child(segment)
	_adjust_segment_size.call_deferred()
	if _background:
		if max_value == 0:
			_background.self_modulate = background_color
		else:
			_background.self_modulate = border_color

func _set_current_value(val: int) -> void:
	current_value = val
	if _segment_container:
		for i in range(max_value):
			var segment:= _segment_container.get_child(i)
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
		else:
			_icon.visible = false

func _set_icon_size(val: Vector2) -> void:
	icon_size = val
	if _icon:
		_icon.custom_minimum_size = icon_size
