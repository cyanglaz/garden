class_name GUIMapTooltip
extends GUITooltip

var TYPE_COLORS:Dictionary = {
	MapNode.NodeType.NORMAL: Constants.COLOR_GREEN3,
	MapNode.NodeType.ELITE: Constants.COLOR_ORANGE2,
	MapNode.NodeType.BOSS: Constants.COLOR_RED,
	MapNode.NodeType.SHOP: Constants.COLOR_YELLOW2,
	MapNode.NodeType.TOWN: Constants.COLOR_BLUE_3,
	MapNode.NodeType.CHEST: Constants.COLOR_PURPLE2,
	MapNode.NodeType.EVENT: Constants.COLOR_BLUE_GRAY_1,
}

@onready var description: RichTextLabel = %Description

func _update_with_tooltip_request() -> void:
	var map_node:MapNode = _tooltip_request.data as MapNode
	var title := ""
	var color:Color = TYPE_COLORS[map_node.type]
	match map_node.type:
		MapNode.NodeType.NORMAL:
			title = Util.get_localized_string("MAP_NODE_TYPE_NORMAL")
		MapNode.NodeType.ELITE:
			title = Util.get_localized_string("MAP_NODE_TYPE_ELITE")
		MapNode.NodeType.BOSS:
			title = Util.get_localized_string("MAP_NODE_TYPE_BOSS")
		MapNode.NodeType.SHOP:
			title = Util.get_localized_string("MAP_NODE_TYPE_SHOP") 
		MapNode.NodeType.TOWN:
			title = Util.get_localized_string("MAP_NODE_TYPE_TOWN")
		MapNode.NodeType.CHEST:
			title = Util.get_localized_string("MAP_NODE_TYPE_CHEST")
		MapNode.NodeType.EVENT:
			title = Util.get_localized_string("MAP_NODE_TYPE_EVENT")
	description.text = title
	description.text = Util.convert_to_bbc_highlight_text(title, color)
