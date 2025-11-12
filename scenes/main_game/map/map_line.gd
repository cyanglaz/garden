class_name MapLine
extends Line2D

const NODE_STATE_COLORS:Dictionary = {
	MapNode.NodeState.NORMAL: Constants.COLOR_BLUE_GRAY_1,
	MapNode.NodeState.CURRENT: Constants.COLOR_GREEN3,
	MapNode.NodeState.NEXT: Constants.COLOR_YELLOW2,
	MapNode.NodeState.COMPLETED: Constants.COLOR_GREEN3,
	MapNode.NodeState.UNREACHABLE: Constants.COLOR_GRAY2,
}

func update_with_line(from_p:Vector2, to_p:Vector2, from_node_state:MapNode.NodeState, to_node_state:MapNode.NodeState) -> void:
	clear_points()
	add_point(from_p)
	add_point(to_p)
	_set_line_color(from_node_state, to_node_state)

func _set_line_color(from_node_state:MapNode.NodeState, to_node_state:MapNode.NodeState) -> void:
	if from_node_state == MapNode.NodeState.UNREACHABLE || to_node_state == MapNode.NodeState.UNREACHABLE:
		default_color = NODE_STATE_COLORS[MapNode.NodeState.UNREACHABLE]
	elif to_node_state == MapNode.NodeState.NEXT:
		
		pass
	else:
		default_color = NODE_STATE_COLORS[to_node_state]
