class_name GUITooltip
extends Control

signal tool_tip_shown()

const OFFSCREEN_PADDING := 6
const STICKY_TIME := 0.7
const TOOLTIP_MOUSE_OFFSET:float = 2.0

@export var outline_color:Color = Constants.COLOR_WHITE: set = _set_outline_color

@onready var _border: NinePatchRect = %Border

enum TooltipPosition {
	RIGHT,
	TOP_RIGHT,
	TOP,
	BOTTOM,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	LEFT_TOP,
	LEFT,
}

var tooltip_position:TooltipPosition = TooltipPosition.RIGHT: set = _set_tooltip_position
var host_view_size:Vector2
var mouse_in:bool = false
var anchor_to_mouse:bool = false
var has_outline:bool = false: set = _set_has_outline

var _showing := false
var triggering_global_rect:Rect2 = Rect2()
var _tooltip_request:TooltipRequest = null

func _ready() -> void:
	if _tooltip_request:
		_update_with_tooltip_request()
	_set_tooltip_position(tooltip_position)

func update_with_request(tooltip_request:TooltipRequest) -> void:
	tooltip_position = tooltip_request.tooltip_position
	_tooltip_request = tooltip_request
	if is_inside_tree():
		_update_with_tooltip_request()

func show_tooltip() -> void:
	show()
	tool_tip_shown.emit()
	_showing = true

func try_remove_tooltip() -> void:
	queue_free()

func update_anchors() -> void:	
	anchor_top = 0
	anchor_bottom = 0
	anchor_left = 0
	anchor_right = 0
	grow_vertical = Control.GROW_DIRECTION_BOTH
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	offset_top = 0
	offset_bottom = 0
	offset_left = 0
	offset_right = 0
	match tooltip_position:
		TooltipPosition.TOP_RIGHT:
			anchor_left = 0
			anchor_right = 0
			anchor_bottom = 1
			anchor_top = 1
			grow_vertical = Control.GROW_DIRECTION_BEGIN
			grow_horizontal = Control.GROW_DIRECTION_END
		TooltipPosition.RIGHT:
			anchor_left = 1
			anchor_right = 1
			grow_vertical = Control.GROW_DIRECTION_END
			grow_horizontal = Control.GROW_DIRECTION_END
		TooltipPosition.TOP:
			anchor_right = 0.5
			anchor_left = 0.5
			anchor_bottom = 0
			anchor_top = 1
			grow_horizontal = Control.GROW_DIRECTION_BOTH
			grow_vertical = Control.GROW_DIRECTION_END
		TooltipPosition.LEFT_TOP:		
			anchor_right = 0
			anchor_left = 0
			anchor_bottom = 1
			anchor_top = 1
			grow_horizontal = Control.GROW_DIRECTION_END
			grow_vertical = Control.GROW_DIRECTION_END
		TooltipPosition.LEFT:
			anchor_right = 0
			anchor_left = 0
			anchor_bottom = 0
			anchor_top = 0
			grow_horizontal = Control.GROW_DIRECTION_END
			grow_vertical = Control.GROW_DIRECTION_BEGIN
		TooltipPosition.BOTTOM_LEFT:
			anchor_right = 0
			anchor_left = 0
			anchor_bottom = 1
			anchor_top = 1
			grow_horizontal = Control.GROW_DIRECTION_BEGIN
			grow_vertical = Control.GROW_DIRECTION_END
		TooltipPosition.BOTTOM_RIGHT:
			anchor_right = 1
			anchor_left = 1
			anchor_bottom = 1
			anchor_top = 1
			grow_horizontal = Control.GROW_DIRECTION_END
			grow_vertical = Control.GROW_DIRECTION_END
		# TooltipPosition.BOTTOM:
		# 	anchor_right = 0.5
		# 	anchor_left = 0.5
		# 	anchor_bottom = 1
		# 	anchor_top = 0
		# 	grow_horizontal = Control.GROW_DIRECTION_BOTH
		# 	grow_vertical = Control.GROW_DIRECTION_END

func adjust_positions() -> void:
	_adjust_position_if_outside_screen()

func hide_tooltip() -> void:
	hide()

func _adjust_position_if_outside_screen() -> void:
	if get_screen_position().x < OFFSCREEN_PADDING:
		# exceeds left side of screen
		global_position.x += -(get_screen_position().x) + OFFSCREEN_PADDING
	elif get_screen_position().x + size.x > get_viewport_rect().size.x - OFFSCREEN_PADDING:
		# exceeds right side of screen
		global_position.x -= get_screen_position().x + size.x - get_viewport_rect().size.x + OFFSCREEN_PADDING
	if get_screen_position().y + size.y > get_viewport_rect().size.y - OFFSCREEN_PADDING:
		# exceeds bottom of screen
		global_position.y -= get_screen_position().y + size.y - get_viewport_rect().size.y + OFFSCREEN_PADDING
	elif get_screen_position().y < OFFSCREEN_PADDING:
		# exceeds top of screen
		global_position.y += -(get_screen_position().y) + OFFSCREEN_PADDING

func _follow_mouse_position() -> void:
	var y_offset:float = 0
	var x_offset:float = 0
	match tooltip_position:
		GUITooltip.TooltipPosition.TOP_RIGHT:
			x_offset = - TOOLTIP_MOUSE_OFFSET
			y_offset = - size.y + TOOLTIP_MOUSE_OFFSET
		GUITooltip.TooltipPosition.TOP:
			x_offset = - size.x/2
			y_offset = - size.y + TOOLTIP_MOUSE_OFFSET
		GUITooltip.TooltipPosition.RIGHT:
			x_offset = - TOOLTIP_MOUSE_OFFSET
			y_offset = - TOOLTIP_MOUSE_OFFSET
		GUITooltip.TooltipPosition.LEFT_TOP:
			x_offset = -size.x + TOOLTIP_MOUSE_OFFSET
			y_offset = - TOOLTIP_MOUSE_OFFSET
		GUITooltip.TooltipPosition.BOTTOM:
			x_offset = - size.x/2
			y_offset = - TOOLTIP_MOUSE_OFFSET
	global_position = get_global_mouse_position() + Vector2(x_offset, y_offset)
	adjust_positions()

#region for override

func _update_with_tooltip_request() -> void:
	pass

#endregion

#region events

func _set_tooltip_position(val:TooltipPosition) -> void:
	tooltip_position = val
	update_anchors()

func _set_has_outline(val:bool) -> void:
	has_outline = val
	if has_outline:
		_border.material.set_shader_parameter("outline_size", 1)
		_border.material.set_shader_parameter("outline_color", outline_color)
	else:
		_border.material.set_shader_parameter("outline_size", 0)

func _set_outline_color(val:Color) -> void:
	outline_color = val
	if _border:
		_border.material.set_shader_parameter("outline_color", val)
