class_name GUIMapLine
extends PanelContainer

@export var color:Color:set = _set_color

const NODE_STATE_COLORS:Dictionary = {
	MapNode.NodeState.NORMAL: Constants.COLOR_BLUE_GRAY_1,
	MapNode.NodeState.CURRENT: Constants.COLOR_GREEN3,
	MapNode.NodeState.NEXT: Constants.COLOR_YELLOW2,
	MapNode.NodeState.COMPLETED: Constants.COLOR_GREEN3,
	MapNode.NodeState.UNREACHABLE: Constants.COLOR_GRAY2,
}

@onready var line: NinePatchRect = %Line
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func update_with_line(from_p:Vector2, to_p:Vector2, from_node_state:MapNode.NodeState, to_node_state:MapNode.NodeState) -> void:
	size.x = from_p.distance_to(to_p)
	#pivot_offset = Vector2(0, size.y/2)
	position = from_p
	rotation = from_p.angle_to_point(to_p)
	_set_line_color(from_node_state, to_node_state)

func _set_line_color(from_node_state:MapNode.NodeState, to_node_state:MapNode.NodeState) -> void:
	if from_node_state == MapNode.NodeState.UNREACHABLE || to_node_state == MapNode.NodeState.UNREACHABLE:
		color = NODE_STATE_COLORS[MapNode.NodeState.UNREACHABLE]
	elif to_node_state == MapNode.NodeState.NEXT:
		animation_player.play("blink_next")
	else:
		color = NODE_STATE_COLORS[to_node_state]

func _set_color(val:Color) -> void:
	color = val
	line.self_modulate = color
