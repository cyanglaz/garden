class_name GUIMapNodeButton
extends GUIBasicButton

const ICON_PATH_PREFIX := "res://resources/sprites/map/map_icon_"

@onready var background: GUIIcon = %Background
@onready var icon: TextureRect = %Icon
@onready var state_indicator: NinePatchRect = %StateIndicator

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
	_set_node_state(node.node_state)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !background:
		return
	background.has_outline = false
	match button_state:
		ButtonState.NORMAL:
			pass
		ButtonState.HOVERED:
			background.has_outline = true
		ButtonState.PRESSED:
			pass
		ButtonState.DISABLED:
			pass
		ButtonState.SELECTED:
			pass

func _set_node_state(val:MapNode.NodeState) -> void:
	match val:
		MapNode.NodeState.NORMAL:
			state_indicator.region_rect.position = Vector2(0, 0)
		MapNode.NodeState.CURRENT:
			state_indicator.region_rect.position = Vector2(0, 12)
		MapNode.NodeState.NEXT:
			state_indicator.region_rect.position = Vector2(0, 24)
		MapNode.NodeState.COMPLETED:
			state_indicator.region_rect.position = Vector2(0, 36)
		MapNode.NodeState.UNREACHABLE:
			state_indicator.region_rect.position = Vector2(0, 48)
