class_name GUIToolCardButton
extends GUIBasicButton

signal _dissolve_finished()
signal use_card_button_pressed()

enum CardState {
	NORMAL,
	HIGHLIGHTED,
	SELECTED,
	UNSELECTED,
}

const SPECIAL_ICON_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_special_icon.tscn")
const VALUE_ICON_PREFIX := "res://resources/sprites/GUI/icons/cards/values/icon_"
const EXHAUST_SOUND := preload("res://resources/sounds/SFX/tool_cards/card_exhaust.wav")

const SIZE := Vector2(40, 54)
const SELECTED_OFFSET := 10.0
const IN_USE_OFFSET := 10.0
const HIGHLIGHTED_OFFSET := 1.0

@onready var _gui_action_list: GUIActionList = %GUIActionList
@onready var _card_container: Control = %CardContainer
@onready var _background: NinePatchRect = %Background
@onready var _title: Label = %Title
@onready var _card_content: Control = %CardContent
@onready var _specials_container: VBoxContainer = %SpecialsContainer
@onready var _cost_icon: TextureRect = %CostIcon
@onready var _rich_text_label: RichTextLabel = %RichTextLabel
@onready var _use_sound: AudioStreamPlayer2D = %UseSound
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _overlay: NinePatchRect = %Overlay
@onready var _gui_use_card_button: GUIUseCardButton = %GUIUseCardButton

var mouse_disabled:bool = true: set = _set_mouse_disabled
var activated := false: set = _set_activated
var card_state:CardState = CardState.NORMAL: set = _set_card_state
var resource_sufficient := false: set = _set_resource_sufficient
var animation_mode := false : set = _set_animation_mode
var display_mode := false
var library_mode := false
var outline_color:Color = Constants.RESOURCE_SUFFICIENT_COLOR: set = _set_outline_color
var has_outline:bool = false: set = _set_has_outline
var tool_data:ToolData: get = _get_tool_data
var _weak_tool_data:WeakRef = weakref(null)
var _container_offset:Vector2 = Vector2.ZERO: set = _set_container_offset

var _weak_actions_tooltip:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	mouse_filter = MOUSE_FILTER_IGNORE
	assert(size == SIZE, "size not match")
	_animation_player.animation_finished.connect(_on_animation_finished)
	_gui_use_card_button.pressed.connect(_on_use_button_pressed)
	_gui_use_card_button.hide()

func update_with_tool_data(td:ToolData) -> void:
	_weak_tool_data = weakref(td)
	if !tool_data.actions.is_empty():
		_gui_action_list.update(tool_data.actions)
	if !tool_data.get_display_description().is_empty():
		_rich_text_label.text = tool_data.get_display_description()
	if tool_data.energy_cost >= 0:
		_cost_icon.texture = load(VALUE_ICON_PREFIX + str(tool_data.energy_cost) + ".png")
	else:
		_cost_icon.hide()
	_title.text = tool_data.display_name
	match tool_data.rarity:
		-1:
			_background.region_rect.position.x = 0
		0:
			_background.region_rect.position.x = 40
		1:
			_background.region_rect.position.x = 80	
		2:
			_background.region_rect.position.x = 120
	Util.remove_all_children(_specials_container)
	for special in tool_data.specials:
		var special_icon := SPECIAL_ICON_SCENE.instantiate()
		var special_id := Util.get_id_for_tool_speical(special)
		special_icon.texture = load(Util.get_image_path_for_resource_id(special_id))
		_specials_container.add_child(special_icon)
	if !td.request_refresh.is_connected(_on_tool_data_refresh):
		td.request_refresh.connect(_on_tool_data_refresh)

func play_move_sound() -> void:
	_play_hover_sound()

func play_use_sound() -> void:
	_use_sound.play()

func play_exhaust_animation() -> void:
	_animation_player.play("dissolve")
	GlobalSoundManager.play_sound(EXHAUST_SOUND)
	await _dissolve_finished

func play_insufficient_energy_animation() -> void:
	await Util.play_error_shake_animation(self, "_container_offset", Vector2.ZERO)

func clear_tooltip() -> void:
	if _weak_actions_tooltip.get_ref():
		_weak_actions_tooltip.get_ref().queue_free()
		_weak_actions_tooltip = weakref(null)

func _update_for_energy(energy:int) -> void:
	if !tool_data:
		return
	if tool_data.energy_cost <= energy:
		resource_sufficient = true
	else:
		resource_sufficient = false
	
func _play_hover_sound() -> void:
	if card_state == CardState.SELECTED:
		return
	super._play_hover_sound()

#region events

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	if activated:
		if !library_mode:
			Singletons.main_game.hovered_data = tool_data
		await Util.create_scaled_timer(Constants.SECONDARY_TOOLTIP_DELAY).timeout
		if mouse_in && !tool_data.actions.is_empty():
			if _weak_actions_tooltip.get_ref():
				return
			_weak_actions_tooltip = weakref(Util.display_tool_card_tooltip(tool_data, self, false, GUITooltip.TooltipPosition.RIGHT, true))

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	Singletons.main_game.hovered_data = null
	clear_tooltip()

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
	else:
		custom_minimum_size = SIZE

func _set_card_state(value:CardState) -> void:
	card_state = value
	match value:
		CardState.NORMAL:
			_container_offset = Vector2.ZERO
			has_outline = false
			_overlay.hide()
			_gui_use_card_button.hide()
			z_index = 0
		CardState.SELECTED:
			_container_offset = Vector2.UP * SELECTED_OFFSET
			has_outline = true
			_overlay.hide()
			if tool_data.need_select_field:
				_gui_use_card_button.hide()
			else:
				_gui_use_card_button.show()
			z_index = 1
		CardState.HIGHLIGHTED:
			_container_offset = Vector2.UP * HIGHLIGHTED_OFFSET
			has_outline = true
			_overlay.hide()
			_gui_use_card_button.hide()
			z_index = 1
		CardState.UNSELECTED:
			_container_offset = Vector2.ZERO
			has_outline = false
			_overlay.show()
			_gui_use_card_button.hide()
			z_index = 0

func _set_container_offset(offset:Vector2) -> void:
	_container_offset = offset
	_card_container.position = offset

func _set_resource_sufficient(value:bool) -> void:
	resource_sufficient = value
	if value:
		_cost_icon.modulate = Constants.RESOURCE_SUFFICIENT_COLOR
		outline_color = Constants.RESOURCE_SUFFICIENT_COLOR
	else:
		if display_mode:
			_cost_icon.modulate = Constants.RESOURCE_SUFFICIENT_COLOR
		else:
			_cost_icon.modulate = Constants.RESOURCE_INSUFFICIENT_COLOR
		outline_color = Constants.RESOURCE_INSUFFICIENT_COLOR
	
func _set_outline_color(value:Color) -> void:
	outline_color = value
	if _background:
		_background.material.set_shader_parameter("outline_color", value)

func _set_has_outline(val:bool) -> void:
	has_outline = val
	if has_outline:
		_background.material.set_shader_parameter("outline_color", outline_color)
		_background.material.set_shader_parameter("outline_size", 1)
	else:
		_background.material.set_shader_parameter("outline_size", 0)

func _on_animation_finished(anim_name:String) -> void:
	if anim_name == "dissolve":
		_dissolve_finished.emit()

func _on_tool_data_refresh() -> void:
	update_with_tool_data(tool_data)

func _on_use_button_pressed() -> void:
	_gui_use_card_button.hide()
	use_card_button_pressed.emit()
