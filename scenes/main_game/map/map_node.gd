class_name MapNode
extends RefCounted

enum NodeType {
	NORMAL,
	ELITE,
	BOSS,
	TAVERN,
	SHOP,
	CHEST,
	EVENT,
}

enum NodeState {
	NORMAL,
	CURRENT,
	NEXT,
	COMPLETED,
	UNREACHABLE,
}

var type:NodeType
var node_state:NodeState

# Grid coordinates within the generated map
var grid_coordinates:Vector2i = Vector2i.ZERO

# Forward connections to the next row
var next_nodes:Array = []
var parent_node:MapNode = null:set = _set_parent_node, get = _get_parent_node

var _weak_parent_node:WeakRef = weakref(null)

func connect_to(next_node) -> void:
	if next_node in next_nodes:
		return
	next_nodes.append(next_node)
	next_node.parent_node = self

func is_connected_to(next_node) -> bool:
	return next_node.parent_node == self

func save() -> Dictionary:
	return {
		"type": int(type),
		"grid_coordinates": grid_coordinates,
		"next": next_nodes.map(func(n): return {
			"grid_coordinates": n.grid_coordinates,
			"type": int(n.type),
		})
	}

func log() -> void:
	var type_str := _type_to_string(type)
	var next_coords := next_nodes.map(func(n): return "(%s,%s:%s)" % [str(n.grid_coordinates.x), str(n.grid_coordinates.y), _type_to_string(n.type)])
	print("Node (", grid_coordinates.x, ",", grid_coordinates.y, ") ", type_str, " -> ", next_coords)

func _type_to_string(t:NodeType) -> String:
	match t:
		NodeType.NORMAL:
			return "NORMAL"
		NodeType.ELITE:
			return "ELITE"
		NodeType.BOSS:
			return "BOSS"
		NodeType.SHOP:
			return "SHOP"
		NodeType.TAVERN:
			return "TAVERN"
		NodeType.CHEST:
			return "CHEST"
		NodeType.EVENT:
			return "EVENT"
		_:
			return "UNKNOWN"

func _set_parent_node(value:MapNode) -> void:
	_weak_parent_node = weakref(value)

func _get_parent_node() -> MapNode:
	return _weak_parent_node.get_ref()
