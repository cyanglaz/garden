class_name GUIMapNode
extends PanelContainer

const ICON_PATH_PREFIX := "res://resources/sprites/map/map_icon_"

@onready var background: GUIIcon = %Background
@onready var icon: TextureRect = %Icon

func update_with_node(node:MapNode) -> void:
	match node.type:
		MapNode.NodeType.NORMAL:
			icon.texture = load(ICON_PATH_PREFIX + "normal.png")
		MapNode.NodeType.ELITE:
			icon.texture = load(ICON_PATH_PREFIX + "elite.png")
		MapNode.NodeType.BOSS:
			icon.texture = load(ICON_PATH_PREFIX + "boss.png")
		MapNode.NodeType.SHOP:
			icon.texture = load(ICON_PATH_PREFIX + "shop.png")
		MapNode.NodeType.TAVERN:
			icon.texture = load(ICON_PATH_PREFIX + "tavern.png")
		MapNode.NodeType.CHEST:
			icon.texture = load(ICON_PATH_PREFIX + "chest.png")
		MapNode.NodeType.EVENT:
			icon.texture = load(ICON_PATH_PREFIX + "event.png")
