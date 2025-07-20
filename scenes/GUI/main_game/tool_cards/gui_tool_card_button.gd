class_name GUIToolCardButton
extends GUIBasicButton

const SIZE := Vector2(36, 48)
const SELECTED_OFFSET := 6.0
const HIGHLIGHTED_OFFSET := 1.0
const TOOLTIP_DELAY := 0.2
const RESOURCE_INSUFFICIENT_COLOR := Constants.COLOR_GRAY3
const RESOURCE_SUFFICIENT_COLOR := Constants.COLOR_PURPLE0
const CARD_HOVER_SOUND := preload("res://resources/sounds/SFX/other/tool_cards/card_hover.wav")
const CARD_SELECT_SOUND := preload("res://resources/sounds/SFX/other/tool_cards/card_select.wav")

@onready var _gui_generic_description: GUIGenericDescription = %GUIGenericDescription
@onready var _card_container: Control = %CardContainer
@onready var _background: NinePatchRect = %Background
@onready var _cost_label: Label = %CostLabel
@onready var _title: Label = %Title
@onready var _highlight_border: NinePatchRect = %HighlightBorder
@onready var _card_content: VBoxContainer = %CardContent

var mouse_disabled:bool = false: set = _set_mouse_disabled
var activated := false: set = _set_activated
var selected := false: set = _set_selected
var highlighted := false: set = _set_highlighted
var resource_sufficient := false: set = _set_resourcet_sufficient
var animation_mode := false : set = _set_animation_mode
var _tool_data:ToolData: get = _get_tool_data
var _weak_tool_data:WeakRef = weakref(null)
var _container_offset:float = 0.0: set = _set_container_offset

var _weak_actions_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	mouse_filter = MOUSE_FILTER_IGNORE
	assert(size == SIZE, "size not match")
	_highlight_border.hide()
	_highlight_border.self_modulate = RESOURCE_SUFFICIENT_COLOR

func update_with_tool_data(tool_data:ToolData) -> void:
	_weak_tool_data = weakref(tool_data)
	_gui_generic_description.update(tool_data.actions, tool_data.get_display_description())
	_cost_label.text = str(tool_data.energy_cost)
	_title.text = tool_data.display_name
	match tool_data.rarity:
		0:
			_background.region_rect.position.x = 0
		1:
			_background.region_rect.position.x = 36
		2:
			_background.region_rect.position.x = 72


func play_move_sound() -> void:
	_sound_hover.play()

func _update_for_energy(energy:int) -> void:
	if !_tool_data:
		return
	if _tool_data.energy_cost <= energy:
		resource_sufficient = true
	else:
		resource_sufficient = false

#region events

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	if activated:
		await Util.create_scaled_timer(TOOLTIP_DELAY).timeout
		if mouse_in:
			_weak_actions_tooltip = weakref(Util.display_actions_tooltip(_tool_data.actions, self, false, GUITooltip.TooltipPosition.RIGHT, true))

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	if _weak_actions_tooltip.get_ref():
		_weak_actions_tooltip.get_ref().queue_free()
		_weak_actions_tooltip = weakref(null)

func _on_energy_tracker_value_updated(energy_tracker:ResourcePoint) -> void:
	_update_for_energy(energy_tracker.value)

#endregion

#region setters/getters
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
	_card_content.visible = !value
	if value:
		custom_minimum_size = Vector2.ZERO
		#_card_margin_container.custom_minimum_size = Vector2.ZERO
		selected = false
		highlighted = false
	else:
		custom_minimum_size = SIZE

func _set_selected(value:bool) -> void:
	selected = value
	if value:
		_container_offset = SELECTED_OFFSET
		_highlight_border.show()
	else:
		_set_highlighted(highlighted)

func _set_highlighted(value:bool) -> void:
	highlighted = value
	if selected:
		return
	if value:
		_highlight_border.show()
		_container_offset = HIGHLIGHTED_OFFSET
	else:
		_highlight_border.hide()
		_container_offset = 0.0

func _set_container_offset(offset:float) -> void:
	_container_offset = offset
	_card_container.position.y = -offset

func _get_hover_sound() -> AudioStream:
	return CARD_HOVER_SOUND

func _get_click_sound() -> AudioStream:
	return CARD_SELECT_SOUND

func _set_resourcet_sufficient(value:bool) -> void:
	resource_sufficient = value
	if value:
		_cost_label.add_theme_color_override("font_color", RESOURCE_SUFFICIENT_COLOR)
		_highlight_border.modulate = RESOURCE_SUFFICIENT_COLOR
	else:
		_cost_label.add_theme_color_override("font_color", RESOURCE_INSUFFICIENT_COLOR)
		_highlight_border.modulate = RESOURCE_INSUFFICIENT_COLOR
