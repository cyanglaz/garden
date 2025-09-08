class_name GUIToolCardButton
extends GUIBasicButton

signal _dissolve_finished()
signal exhaust_sound_finished()

enum CardState {
	NORMAL,
	HIGHLIGHTED,
	SELECTED,
}

const SPECIAL_ICON_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_special_icon.tscn")
const VALUE_ICON_PREFIX := "res://resources/sprites/GUI/icons/cards/values/icon_"

const SIZE := Vector2(38, 52)
const SELECTED_OFFSET := 6.0
const IN_USE_OFFSET := 10.0
const HIGHLIGHTED_OFFSET := 1.0
const TOOLTIP_DELAY := 0.2
const CARD_HOVER_SOUND := preload("res://resources/sounds/SFX/tool_cards/card_hover.wav")
const CARD_SELECT_SOUND := preload("res://resources/sounds/SFX/tool_cards/card_select.wav")

@onready var _gui_action_list: GUIActionList = %GUIActionList
@onready var _card_container: Control = %CardContainer
@onready var _background: NinePatchRect = %Background
@onready var _title: Label = %Title
@onready var _highlight_border: NinePatchRect = %HighlightBorder
@onready var _card_content: VBoxContainer = %CardContent
@onready var _specials_container: VBoxContainer = %SpecialsContainer
@onready var _cost_icon: TextureRect = %CostIcon
@onready var _rich_text_label: RichTextLabel = %RichTextLabel
@onready var _use_sound: AudioStreamPlayer2D = %UseSound
@onready var _exhaust_sound: AudioStreamPlayer2D = %ExhaustSound
@onready var _animation_player: AnimationPlayer = %AnimationPlayer

var mouse_disabled:bool = false: set = _set_mouse_disabled
var activated := false: set = _set_activated
var card_state:CardState = CardState.NORMAL: set = _set_card_state
var resource_sufficient := false: set = _set_resource_sufficient
var animation_mode := false : set = _set_animation_mode
var display_mode := false
var _tool_data:ToolData: get = _get_tool_data
var _weak_tool_data:WeakRef = weakref(null)
var _container_offset:float = 0.0: set = _set_container_offset

var _weak_actions_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	mouse_filter = MOUSE_FILTER_IGNORE
	assert(size == SIZE, "size not match")
	_highlight_border.hide()
	_highlight_border.self_modulate = Constants.RESOURCE_SUFFICIENT_COLOR
	_animation_player.animation_finished.connect(_on_animation_finished)

func update_with_tool_data(tool_data:ToolData) -> void:
	_weak_tool_data = weakref(tool_data)
	if tool_data.actions.is_empty():
		_rich_text_label.text = tool_data.get_display_description()
	else:
		_gui_action_list.update(tool_data.actions)
	if tool_data.energy_cost >= 0:
		_cost_icon.texture = load(VALUE_ICON_PREFIX + str(tool_data.energy_cost) + ".png")
	else:
		_cost_icon.hide()
	_title.text = tool_data.display_name
	match tool_data.rarity:
		-1:
			_background.region_rect.position.x = 0
		0:
			_background.region_rect.position.x = 38	
		1:
			_background.region_rect.position.x = 76
		2:
			_background.region_rect.position.x = 114
	for special in tool_data.specials:
		var special_icon := SPECIAL_ICON_SCENE.instantiate()
		var special_id := Util.get_id_for_tool_speical(special)
		special_icon.texture = load(Util.get_image_path_for_resource_id(special_id))
		_specials_container.add_child(special_icon)

func play_move_sound() -> void:
	_sound_hover.play()

func play_use_sound() -> void:
	_use_sound.play()

func play_exhaust_animation() -> void:
	_animation_player.play("dissolve")
	await _dissolve_finished

func play_exhaust_sound() -> void:
	_exhaust_sound.play()
	await _exhaust_sound.finished
	exhaust_sound_finished.emit()

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
		if mouse_in && !_tool_data.actions.is_empty():
			if _weak_actions_tooltip.get_ref():
				return
			_weak_actions_tooltip = weakref(Util.display_tool_card_tooltip(_tool_data, self, false, GUITooltip.TooltipPosition.RIGHT, true))

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
	if !display_mode:
		var energy_tracker := Singletons.main_game.energy_tracker
		_update_for_energy(energy_tracker.value)
		energy_tracker.value_update.connect(_on_energy_tracker_value_updated.bind(energy_tracker))

func _set_animation_mode(value:bool) -> void:
	animation_mode = value
	_card_content.visible = !value
	if value:
		custom_minimum_size = Vector2.ZERO
		#_card_margin_container.custom_minimum_size = Vector2.ZERO
		card_state = CardState.NORMAL
	else:
		custom_minimum_size = SIZE

func _set_card_state(value:CardState) -> void:
	card_state = value
	match value:
		CardState.NORMAL:
			_container_offset = 0.0
			_highlight_border.hide()
		CardState.SELECTED:
			_container_offset = SELECTED_OFFSET
			_highlight_border.show()
		CardState.HIGHLIGHTED:
			_container_offset = HIGHLIGHTED_OFFSET
			_highlight_border.show()

func _set_container_offset(offset:float) -> void:
	_container_offset = offset
	_card_container.position.y = -offset

func _get_hover_sound() -> AudioStream:
	if display_mode:
		return super._get_hover_sound()
	return CARD_HOVER_SOUND

func _get_click_sound() -> AudioStream:
	if display_mode:
		return super._get_click_sound()
	return CARD_SELECT_SOUND

func _set_resource_sufficient(value:bool) -> void:
	resource_sufficient = value
	if value:
		_cost_icon.modulate = Constants.RESOURCE_SUFFICIENT_COLOR
		_highlight_border.modulate = Constants.RESOURCE_SUFFICIENT_COLOR
	else:
		if display_mode:
			_cost_icon.modulate = Constants.RESOURCE_SUFFICIENT_COLOR
		else:
			_cost_icon.modulate = Constants.RESOURCE_INSUFFICIENT_COLOR
		_highlight_border.modulate = Constants.RESOURCE_INSUFFICIENT_COLOR
	
func _on_animation_finished(anim_name:String) -> void:
	if anim_name == "dissolve":
		_dissolve_finished.emit()
