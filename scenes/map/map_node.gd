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

var type:NodeType

# Grid coordinates within the generated map
var row:int = -1
var column:int = -1

# Forward connections to the next row
var next_nodes:Array = []

func connect_to(next_node) -> void:
	if next_node in next_nodes:
		return
	next_nodes.append(next_node)

func save() -> Dictionary:
	return {
		"type": int(type),
		"row": row,
		"column": column,
		"next": next_nodes.map(func(n): return {
			"row": n.row,
			"column": n.column,
			"type": int(n.type),
		})
	}

func log() -> void:
	var type_str := _type_to_string(type)
	var next_coords := next_nodes.map(func(n): return "(%s,%s:%s)" % [str(n.row), str(n.column), _type_to_string(n.type)])
	print("Node (", row, ",", column, ") ", type_str, " -> ", next_coords)

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
