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
var node_state:NodeState = NodeState.NORMAL

# Grid coordinates within the generated map
var grid_coordinates:Vector2i = Vector2i.ZERO

# Forward connections to the next row
var next_nodes:Array = []
var weak_parent_nodes:Array[WeakRef] = []

func connect_to(next_node) -> void:
	if next_node in next_nodes:
		return
	next_nodes.append(next_node)
	next_node.weak_parent_nodes.append(weakref(self))

func is_connected_to(next_node) -> bool:
	return next_node.weak_parent_nodes.any(func(n): return n.get_ref() == self)

func save() -> Dictionary:
	return {
		"type": int(type),
		"grid_coordinates": grid_coordinates,
		"next": next_nodes.map(func(n): return {
			"grid_coordinates": n.grid_coordinates,
			"type": int(n.type),
		})
	}

func log_node() -> void:
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
