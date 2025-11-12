class_name MapMain
extends Node2D

signal node_selected(node:MapNode)

@onready var gui: GUIMapMain = %GUIMapMain
@onready var map_node_container: MapNodeContainer = %MapNodeContainer

var map_generator:MapGenerator = MapGenerator.new()
var root_node:MapNode:get = _get_root_node
var layers:Array
var _current_map_node:MapNode

func _ready() -> void:
	map_node_container.node_button_pressed.connect(_on_node_selected)
	map_node_container.node_hovered.connect(_on_node_hovered)
	map_generator.generate(randi())
	#update_with_map(map_generator.layers)
	generate_map(randi())

func show_map() -> void:
	gui.show()

func hide_map() -> void:
	gui.hide()

func generate_map(rand_seed:int = 0) -> void:
	layers = map_generator.generate(rand_seed)
	_current_map_node = root_node
	_update_with_map()

func get_node_count(node_type:MapNode.NodeType) -> int:
	return layers.reduce(func(acc, layer): return acc + layer.filter(func(node): return node.type == node_type).size(), 0)

func complete_current_node() -> void:
	# Order of the operations is important
	_mark_current_node_and_next_nodes(_current_map_node)
	_mark_unreachable_nodes()
	#_mark_reachable_nodes()
	gui.redraw(layers)

func _update_with_map() -> void:
	map_node_container.update_with_map_nodes(layers)
	#gui.update_with_map(layers)

func _mark_current_node_and_next_nodes(completed_node:MapNode) -> void:
	var layer_index := completed_node.grid_coordinates.x
	var same_layer_nodes:Array = layers[layer_index]
	for node:MapNode in same_layer_nodes:
		if node == completed_node:
			node.node_state = MapNode.NodeState.CURRENT
			for next_node:MapNode in node.next_nodes:
				next_node.node_state = MapNode.NodeState.NEXT
		else:
			node.node_state = MapNode.NodeState.UNREACHABLE

func _mark_unreachable_nodes() -> void:
	for layer_nodes in layers:		
		for layer_node in layer_nodes:
			if layer_node.weak_parent_nodes.size() > 0 && layer_node.weak_parent_nodes.all(func(weak_parent_node:WeakRef): return weak_parent_node.get_ref().node_state == MapNode.NodeState.UNREACHABLE):
				layer_node.node_state = MapNode.NodeState.UNREACHABLE

#func _mark_reachable_nodes() -> void:
#	for layer_nodes in layers:
#		for layer_node in layer_nodes:
#			if layer_node.parent_node && layer_node.parent_node.node_state == MapNode.NodeState.NEXT:
#				layer_node.node_state = MapNode.NodeState.NORMAL

func _on_node_selected(node:MapNode) -> void:
	_current_map_node = node
	node_selected.emit(node)

func _on_node_hovered(hovered:bool, node:MapNode) -> void:
	gui.update_tooltip(node, hovered)

func _get_root_node() -> MapNode:
	assert(layers.size() > 0, "map not generated, root node not available")
	return layers[0].front()
