class_name GUIMapLine
extends PanelContainer

enum LineState {
	NORMAL,
	NEXT,
	COMPLETED,
	UNREACHABLE,
}

const LINE_STATE_COLORS:Dictionary = {
	LineState.NORMAL: Constants.COLOR_BLUE_GRAY_1,
	LineState.NEXT: Constants.COLOR_ORANGE2,
	LineState.COMPLETED: Constants.COLOR_GREEN3,
	LineState.UNREACHABLE: Constants.COLOR_GRAY2,
}

@onready var line: NinePatchRect = %Line

var line_state:LineState = LineState.NORMAL: set = _set_line_state

func update_with_line(from_p:Vector2, to_p:Vector2) -> void:
	size.x = from_p.distance_to(to_p)
	#pivot_offset = Vector2(0, size.y/2)
	position = from_p
	rotation = from_p.angle_to_point(to_p)
	line_state = LineState.NORMAL

func _set_line_state(val:LineState) -> void:
	line_state = val
	line.modulate = LINE_STATE_COLORS[val]
