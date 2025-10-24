class_name GUITooltipContainer
extends Control

const TOOLTIP_OFFSET:float = 2.0

func _ready() -> void:
	Events.request_display_tooltip.connect(_on_request_display_tooltip)

func _on_request_display_tooltip(gui_tooltip:GUITooltip, on_control_node:Control, anchor_mouse:bool, world_space:bool) -> void:
	add_child(gui_tooltip)
	_display_tool_tip(gui_tooltip, on_control_node, anchor_mouse, world_space)

func _display_tool_tip(tooltip:Control, on_control_node:Control, anchor_mouse:bool, world_space:bool = false) -> void:
	tooltip.show()
	if tooltip is GUITooltip:
		tooltip.anchor_to_mouse = anchor_mouse
		tooltip.show_tooltip()
		tooltip.update_anchors()
	if anchor_mouse && on_control_node:
		tooltip.triggering_global_rect = on_control_node.get_global_rect()
		return
	if !on_control_node:
		return
	var y_offset:float = 0
	var x_offset:float = 0
	match tooltip.tooltip_position:
		GUITooltip.TooltipPosition.TOP_RIGHT:
			x_offset = on_control_node.size.x + TOOLTIP_OFFSET
			y_offset = - tooltip.size.y + on_control_node.size.y - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.TOP:
			x_offset = on_control_node.size.x/2 - tooltip.size.x/2
			y_offset = - tooltip.size.y - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.RIGHT:
			x_offset = on_control_node.size.x + TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.LEFT_TOP:
			x_offset = -tooltip.size.x - TOOLTIP_OFFSET
			y_offset = - tooltip.size.y + on_control_node.size.y - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.LEFT:
			x_offset = -tooltip.size.x - TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.BOTTOM:
			x_offset = on_control_node.size.x/2 - tooltip.size.x/2
			y_offset = on_control_node.size.y + TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.BOTTOM_LEFT:
			x_offset = -tooltip.size.x + on_control_node.size.x
			y_offset = on_control_node.size.y + TOOLTIP_OFFSET
		GUITooltip.TooltipPosition.BOTTOM_RIGHT:
			y_offset = on_control_node.size.y + TOOLTIP_OFFSET
	var reference_position := on_control_node.global_position
	if world_space:
		assert(on_control_node)
		reference_position = Util.get_node_canvas_position(on_control_node)
	tooltip.global_position = reference_position + Vector2(x_offset, y_offset)
	if tooltip is GUITooltip:
		_adjust_tooltip_position(tooltip, on_control_node, world_space)

func _adjust_tooltip_position(tooltip:GUITooltip, on_control_node:Control, world_space:bool = false) -> void:
	match tooltip.tooltip_position:
		GUITooltip.TooltipPosition.TOP_RIGHT:
			pass
		GUITooltip.TooltipPosition.TOP:
			if tooltip.get_screen_position().y < GUITooltip.OFFSCREEN_PADDING:
				_display_tool_tip(tooltip, on_control_node, false, world_space)
		GUITooltip.TooltipPosition.RIGHT:
			pass
		GUITooltip.TooltipPosition.BOTTOM:
			pass
	tooltip.adjust_positions()
