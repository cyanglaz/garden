class_name GUIMapNodeButton
extends GUIBasicButton

const ICON_PATH_PREFIX := "res://resources/sprites/map/map_icon_"

@onready var icon: TextureRect = %Icon

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
		MapNode.NodeType.TAVERN:
			icon.texture = load(ICON_PATH_PREFIX + "tavern.png")
		MapNode.NodeType.CHEST:
			icon.texture = load(ICON_PATH_PREFIX + "chest.png")
		MapNode.NodeType.EVENT:
			icon.texture = load(ICON_PATH_PREFIX + "event.png")
	_set_node_state(node.node_state)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if !icon:
		return
	icon.has_outline = false
	if button_state in [ButtonState.HOVERED, ButtonState.SELECTED]:
		icon.has_outline = true
	else:
		icon.has_outline = false

func _set_node_state(val:MapNode.NodeState) -> void:
	node_state = val
	#if val in [MapNode.NodeState.COMPLETED, MapNode.NodeState.UNREACHABLE]:
		#overlay.show()
	#else:
		#overlay.hide()
	#match val:
		#MapNode.NodeState.NORMAL:
			#state_indicator.region_rect.position = Vector2(0, 0)
		#MapNode.NodeState.CURRENT:
			#state_indicator.region_rect.position = Vector2(16, 0)
		#MapNode.NodeState.NEXT:
			#state_indicator.region_rect.position = Vector2(32, 0)
		#MapNode.NodeState.COMPLETED:
			#state_indicator.region_rect.position = Vector2(48, 0)
		#MapNode.NodeState.UNREACHABLE:
			#state_indicator.region_rect.position = Vector2(64, 0)

func _handle_press_up() -> void:
	if node_state in [MapNode.NodeState.COMPLETED, MapNode.NodeState.UNREACHABLE, MapNode.NodeState.CURRENT]:
		return
	super._handle_press_up()

func _play_hover_sound() -> void:
	if node_state in [MapNode.NodeState.COMPLETED, MapNode.NodeState.UNREACHABLE, MapNode.NodeState.CURRENT]:
		return
	super._play_hover_sound()
