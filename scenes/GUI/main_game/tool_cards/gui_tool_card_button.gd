class_name GUIToolCardButton
extends GUIBasicButton

const SIZE := Vector2(36, 48)
const CARD_HOVER_SOUND := preload("res://resources/sounds/SFX/other/tool_cards/card_hover.wav")
const CARD_SELECT_SOUND := preload("res://resources/sounds/SFX/other/tool_cards/card_select.wav")

@onready var _gui_generic_description: GUIGenericDescription = %GUIGenericDescription
@onready var _card_container: Control = %CardContainer
@onready var _background: NinePatchRect = %Background
@onready var _cost_label: Label = %CostLabel

var container_offset:float = 0.0: set = _set_container_offset
var mouse_disabled:bool = false: set = _set_mouse_disabled
var activated := false: set = _set_activated
var _tool_data:ToolData: get = _get_tool_data
var _weak_tool_data:WeakRef = weakref(null)
var _default_button_state:GUIBasicButton.ButtonState = GUIBasicButton.ButtonState.NORMAL
var animation_mode := false : set = _set_animation_mode

func _ready() -> void:
	super._ready()
	mouse_filter = MOUSE_FILTER_IGNORE
	assert(size == SIZE, "size not match")

func update_with_tool_data(tool_data:ToolData) -> void:
	_weak_tool_data = weakref(tool_data)
	_gui_generic_description.update(tool_data.display_name, tool_data.actions, tool_data.get_display_description())
	_cost_label.text = str(tool_data.energy_cost)

func play_move_sound() -> void:
	_sound_hover.play()

func _update_for_energy(energy:int) -> void:
	if !_tool_data:
		return
	if _tool_data.energy_cost <= energy:
		_default_button_state = GUIBasicButton.ButtonState.NORMAL
	else:
		_default_button_state = GUIBasicButton.ButtonState.DISABLED
	_set_button_state(_default_button_state)

func _set_button_state(bs:GUIBasicButton.ButtonState) -> void:
	if _default_button_state == GUIBasicButton.ButtonState.DISABLED:
		bs = GUIBasicButton.ButtonState.DISABLED
	super._set_button_state(bs)
	match bs:
		GUIBasicButton.ButtonState.HOVERED:
			_background.region_rect.position.y = 16
		GUIBasicButton.ButtonState.NORMAL:
			_background.region_rect.position.y = 0
		GUIBasicButton.ButtonState.DISABLED:
			_background.region_rect.position.y = 32
		GUIBasicButton.ButtonState.PRESSED, GUIBasicButton.ButtonState.SELECTED:
			_background.region_rect.position.y = 16

func _set_container_offset(offset:float) -> void:
	container_offset = offset
	_card_container.position.y = offset

func _get_hover_sound() -> AudioStream:
	return CARD_HOVER_SOUND

func _get_click_sound() -> AudioStream:
	return CARD_SELECT_SOUND

func _set_mouse_disabled(value:bool) -> void:
	if !activated:
		return
	mouse_disabled = value
	if value:
		mouse_filter = MOUSE_FILTER_IGNORE
	else:
		mouse_filter = MOUSE_FILTER_STOP

func _get_tool_data() -> ToolData:
	return _weak_tool_data.get_ref()

func _set_activated(value:bool) -> void:
	activated = value
	var energy_tracker := Singletons.main_game.energy_tracker
	_update_for_energy(energy_tracker.value)
	energy_tracker.value_update.connect(_on_energy_tracker_value_updated.bind(energy_tracker))

func _set_animation_mode(value:bool) -> void:
	animation_mode = value
	_cost_label.visible = !value
	_gui_generic_description.visible = !value
	custom_minimum_size = Vector2.ZERO
	

func _on_energy_tracker_value_updated(energy_tracker:ResourcePoint) -> void:
	_update_for_energy(energy_tracker.value)
