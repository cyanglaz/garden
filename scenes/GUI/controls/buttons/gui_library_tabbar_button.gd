class_name GUILibraryTabbarButton
extends GUIBasicButton

signal close_button_evoked()

const RESOURCE_ICON_PREFIX := "res://resources/sprites/GUI/icons/resources/icon_"
const PLANT_ICON_PREFIX := "res://resources/sprites/GUI/icons/plants/icon_"
const CARD_ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_card.png"
const BOSS_ICON_PATH := "res://resources/sprites/GUI/icons/resources/icon_boss.png"

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label
@onready var border: NinePatchRect = %Border
@onready var gui_close_button: GUICloseButton = %GUICloseButton

var _weak_data:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	gui_close_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gui_close_button.pressed.connect(func() -> void: close_button_evoked.emit())
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if get_global_rect().has_point(get_global_mouse_position()) || button_state == ButtonState.SELECTED:
		if gui_close_button.button_state == GUIBasicButton.ButtonState.DISABLED:
			gui_close_button.button_state = GUIBasicButton.ButtonState.NORMAL
		if gui_close_button.get_global_rect().has_point(get_global_mouse_position()):
			if gui_close_button.button_state != GUIBasicButton.ButtonState.HOVERED:
				gui_close_button.button_state = GUIBasicButton.ButtonState.HOVERED
		else:
			gui_close_button.button_state = GUIBasicButton.ButtonState.NORMAL
	else:
		if gui_close_button.button_state != GUIBasicButton.ButtonState.DISABLED:
			gui_close_button.button_state = GUIBasicButton.ButtonState.DISABLED

func update_with_data(data:ThingData) -> void:
	_weak_data = weakref(data)
	label.text = data.display_name
	var icon_path:String = _get_reference_button_icon_path(data)
	texture_rect.texture = load(icon_path)

func _press_up() -> void:
	if gui_close_button.get_global_rect().has_point(get_global_mouse_position()):
		gui_close_button._press_up()
	else:
		super._press_up()
	
func _press_down() -> void:
	if gui_close_button.get_global_rect().has_point(get_global_mouse_position()):
		gui_close_button._press_down()
	else:
		super._press_down()

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
