class_name MapLine
extends Line2D

const DOTS_TEXTURE := preload("res://resources/sprites/map/map_line_dots.png")
const SOLID_TEXTURE := preload("res://resources/sprites/map/map_line.png")

const DEFAULT_WIDTH := 1
const DOUBLE_WIDTH := 2

const NODE_STATE_COLORS:Dictionary = {
	MapNode.NodeState.NORMAL: Constants.COLOR_BLUE_GRAY_1,
	MapNode.NodeState.CURRENT: Constants.COLOR_GREEN1,
	MapNode.NodeState.COMPLETED: Constants.COLOR_GREEN1,
	MapNode.NodeState.NEXT: Constants.COLOR_YELLOW2,
	MapNode.NodeState.UNREACHABLE: Constants.COLOR_GRAY2,
}

const NODE_STATE_LINE_TEXTURES:Dictionary = {
	MapNode.NodeState.UNREACHABLE: SOLID_TEXTURE,
	MapNode.NodeState.CURRENT: SOLID_TEXTURE,
	MapNode.NodeState.COMPLETED: SOLID_TEXTURE,
	MapNode.NodeState.NEXT: DOTS_TEXTURE,
	MapNode.NodeState.NORMAL: DOTS_TEXTURE,
}

const NODE_STATE_LINE_WIDTHS:Dictionary = {
	MapNode.NodeState.UNREACHABLE: DOUBLE_WIDTH,
	MapNode.NodeState.CURRENT: DOUBLE_WIDTH,
	MapNode.NodeState.COMPLETED: DOUBLE_WIDTH,
	MapNode.NodeState.NEXT: DEFAULT_WIDTH,
	MapNode.NodeState.NORMAL: DEFAULT_WIDTH,
}

func update_with_line(from_p:Vector2, to_p:Vector2, from_node_state:MapNode.NodeState, to_node_state:MapNode.NodeState) -> void:
	clear_points()
	add_point(from_p)
	add_point(to_p)
	_set_line_color(from_node_state, to_node_state)

func _set_line_color(from_node_state:MapNode.NodeState, to_node_state:MapNode.NodeState) -> void:
	if from_node_state == MapNode.NodeState.UNREACHABLE || to_node_state == MapNode.NodeState.UNREACHABLE:
		default_color = NODE_STATE_COLORS[MapNode.NodeState.UNREACHABLE]
		width = DEFAULT_WIDTH
		texture = DOTS_TEXTURE
	else:
		width = NODE_STATE_LINE_WIDTHS[to_node_state]
		default_color = NODE_STATE_COLORS[to_node_state]
		texture = NODE_STATE_LINE_TEXTURES[to_node_state]
