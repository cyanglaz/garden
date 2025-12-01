class_name GUIMapMain
extends CanvasLayer

@onready var tooltip_anchor: Control = %TooltipAnchor

var _tooltip_id:String = ""

func update_tooltip(node:MapNode, is_shown:bool) -> void:
	if is_shown:
		_tooltip_id = Util.get_uuid()
		Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.MAP, node, _tooltip_id, tooltip_anchor, GUITooltip.TooltipPosition.BOTTOM_LEFT))
	else:
		Events.request_hide_tooltip.emit(_tooltip_id)
