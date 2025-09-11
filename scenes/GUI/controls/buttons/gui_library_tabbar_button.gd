class_name GUILibraryTabbarButton
extends GUIBasicButton

const RESOURCE_ICON_PREFIX := "res://resources/sprites/GUI/icons/resources/icon_"
const PLANT_ICON_PREFIX := "res://resources/sprites/GUI/icons/plants/icon_"
const CARD_ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_card.png"
const BOSS_ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_boss.png"

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label
@onready var border: NinePatchRect = %Border

var _weak_data:WeakRef = weakref(null)
	
func update_with_data(data:ThingData) -> void:
	_weak_data = weakref(data)
	label.text = data.display_name
	var icon_path:String = _get_reference_button_icon_path(data)
	texture_rect.texture = load(icon_path)

func _set_button_state(val:ButtonState) -> void:
	super._set_button_state(val)
	if border:
		match button_state:
			ButtonState.NORMAL:
				border.region_rect.position = Vector2(0, 0)
			ButtonState.PRESSED:
				border.region_rect.position = Vector2(16, 0)
			ButtonState.HOVERED:
				border.region_rect.position = Vector2(32, 0)
			ButtonState.DISABLED:
				border.region_rect.position = Vector2(0, 12)
			ButtonState.SELECTED:
				border.region_rect.position = Vector2(16, 12)

func _get_reference_button_icon_path(data:ThingData) -> String:
	if data is FieldStatusData:
		return str(RESOURCE_ICON_PREFIX, data.id, ".png")
	elif data is ActionData:
		return str(RESOURCE_ICON_PREFIX, data.id, ".png")
	elif data is ToolData:
		return CARD_ICON_PATH
	elif data is PlantData:
		return str(PLANT_ICON_PREFIX, data.id, ".png")
	elif data is LevelData:
		return BOSS_ICON_PATH
	assert(false, "data not implemented")
	return ""
