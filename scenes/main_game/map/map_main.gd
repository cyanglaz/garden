class_name MapMain
extends Node2D

signal node_selected(node:MapNode)

@onready var gui: GUIMapMain = %GUIMapMain

var map_generator:MapGenerator = MapGenerator.new()
var root_node:MapNode:get = _get_root_node
var layers:Array
var _current_map_node:MapNode

func _ready() -> void:
	gui.node_button_pressed.connect(_on_node_selected)
	#map_generator.generate(randi())
	#update_with_map(map_generator.layers)

func show_map() -> void:
	gui.show()

func hide_map() -> void:
	gui.hide()

func generate_map(rand_seed:int = 0) -> void:
	layers = map_generator.generate(rand_seed)
	_current_map_node = root_node
	_update_with_map.call_deferred()

func get_node_count(node_type:MapNode.NodeType) -> int:
	return layers.reduce(func(acc, layer): return acc + layer.filter(func(node): return node.type == node_type).size(), 0)

func complete_current_node() -> void:
	# Order of the operations is important
	_mark_current_node_and_next_nodes(_current_map_node)
	_mark_reachable_nodes(_current_map_node)
	_mark_unreachable_nodes()
	gui.redraw(layers)

func _update_with_map() -> void:
	gui.update_with_map(layers)

func _mark_current_node_and_next_nodes(completed_node:MapNode) -> void:
	for layer_nodes in layers:
		for layer_node in layer_nodes:
			if layer_node.node_state == MapNode.NodeState.CURRENT:
				layer_node.node_state = MapNode.NodeState.COMPLETED
			if layer_node.node_state == MapNode.NodeState.NEXT:
				layer_node.node_state = MapNode.NodeState.UNREACHABLE
	completed_node.node_state = MapNode.NodeState.CURRENT
	for nxt in completed_node.next_nodes:
		nxt.node_state = MapNode.NodeState.NEXT

func _mark_unreachable_nodes() -> void:
	for layer_nodes in layers:		
		for layer_node in layer_nodes:
			if layer_node.node_state == MapNode.NodeState.NORMAL:
				layer_node.node_state = MapNode.NodeState.UNREACHABLE

func _mark_reachable_nodes(current_node:MapNode) -> void:
	for nxt in current_node.next_nodes:
		if nxt.node_state == MapNode.NodeState.UNREACHABLE:
			nxt.node_state = MapNode.NodeState.NORMAL
		_mark_reachable_nodes(nxt)

func _on_node_selected(node:MapNode) -> void:
	_current_map_node = node
	node_selected.emit(node)

func _get_root_node() -> MapNode:
	assert(layers.size() > 0, "map not generated, root node not available")
	return layers[0].front()
