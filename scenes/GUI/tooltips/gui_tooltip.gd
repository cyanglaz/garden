class_name GUITooltip
extends Control

signal tool_tip_shown()

const OFFSCREEN_PADDING := 6
const STICKY_TIME := 0.7
const TOOLTIP_MOUSE_OFFSET:float = 2.0

@onready var _sticky_progress_bar: TextureProgressBar = %StickyProgressBar

enum TooltipPosition {
	TOP_RIGHT,
	RIGHT,
	TOP,
	BOTTOM,
	LEFT,
}

var tooltip_position:TooltipPosition = TooltipPosition.TOP_RIGHT: set = _set_tooltip_position
var host_view_size:Vector2
var mouse_in:bool = false
var anchor_to_mouse:bool = false
var sticky:bool = false: set = _set_sticky
var is_sticked := false
var _showing := false
var _sticky_timer:float = 0.0

var triggering_global_rect:Rect2 = Rect2()

func _ready() -> void:
	_sticky_progress_bar.max_value = STICKY_TIME
	_sticky_progress_bar.value = _sticky_progress_bar.max_value
	_sticky_progress_bar.step = 0.01			

func _process(delta: float) -> void:
	mouse_in = get_global_rect().has_point(get_global_mouse_position())
	if sticky && visible:
		_sticky_timer += delta
		if _sticky_timer > STICKY_TIME:
			is_sticked = true
			_sticky_progress_bar.value = _sticky_progress_bar.max_value
		else:
			_sticky_progress_bar.value = _sticky_timer
		if is_sticked && !anchor_to_mouse:
			return
		if anchor_to_mouse && _showing:
			if is_sticked && !mouse_in:
				#print("_stikcy and not mouse in")
				queue_free()
				return
			elif !is_sticked:
				_follow_mouse_position()
				#print("not sticky yet")
		if triggering_global_rect.size != Vector2.ZERO && !triggering_global_rect.has_point(get_global_mouse_position()):
			try_remove_tooltip()

func show_tooltip() -> void:
	if sticky:
		is_sticked = false
		_sticky_timer = 0
	show()
	tool_tip_shown.emit()
	_showing = true

func try_remove_tooltip() -> void:
	if is_sticked && ((anchor_to_mouse && mouse_in) || !anchor_to_mouse):
		return
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
			grow_vertical = Control.GROW_DIRECTION_BEGIN
		TooltipPosition.LEFT:
			anchor_right = 0
			anchor_left = 0
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
		GUITooltip.TooltipPosition.LEFT:
			x_offset = -size.x + TOOLTIP_MOUSE_OFFSET
			y_offset = - TOOLTIP_MOUSE_OFFSET
		GUITooltip.TooltipPosition.BOTTOM:
			x_offset = - size.x/2
			y_offset = - TOOLTIP_MOUSE_OFFSET
	global_position = get_global_mouse_position() + Vector2(x_offset, y_offset)
	adjust_positions()

#region events

func _set_tooltip_position(val:TooltipPosition) -> void:
	tooltip_position = val
	update_anchors()

func _set_sticky(val:bool) -> void:
	sticky = val
	if val:
		_sticky_progress_bar.value = 0
	else:
		_sticky_progress_bar.value = _sticky_progress_bar.max_value

func _on_visibility_changed() -> void:
	if visible:
		if sticky:
			is_sticked = false
			_sticky_progress_bar.value = 0
