class_name GUIMapNodeButton
extends GUIBasicButton

const ICON_PATH_PREFIX := "res://resources/sprites/map/map_icon_"

@onready var icon: TextureRect = %Icon
@onready var gui_map_node_background: GUIIcon = %GUIMapNodeBackground

var node_state:MapNode.NodeState = MapNode.NodeState.NORMAL: set = _set_node_state

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
		MapNode.NodeType.TOWN:
			icon.texture = load(ICON_PATH_PREFIX + "town.png")
		MapNode.NodeType.CHEST:
			icon.texture = load(ICON_PATH_PREFIX + "chest.png")
		MapNode.NodeType.EVENT:
			icon.texture = load(ICON_PATH_PREFIX + "event.png")
	_set_node_state(node.node_state)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !gui_map_node_background:
		return
	gui_map_node_background.has_outline = false
	if button_state in [ButtonState.HOVERED, ButtonState.SELECTED]:
		gui_map_node_background.has_outline = true
	else:
		gui_map_node_background.has_outline = false

func _set_node_state(val:MapNode.NodeState) -> void:
	node_state = val
	if !gui_map_node_background:
		return
	match val:
		MapNode.NodeState.NORMAL:
			(gui_map_node_background.texture as AtlasTexture).region.position = Vector2(0, 0)
		MapNode.NodeState.CURRENT:
			(gui_map_node_background.texture as AtlasTexture).region.position = Vector2(32, 0)
		MapNode.NodeState.NEXT:
			(gui_map_node_background.texture as AtlasTexture).region.position = Vector2(48, 0)
		MapNode.NodeState.COMPLETED:
			(gui_map_node_background.texture as AtlasTexture).region.position = Vector2(32, 0)
		MapNode.NodeState.UNREACHABLE:
			(gui_map_node_background.texture as AtlasTexture).region.position = Vector2(16, 0)
