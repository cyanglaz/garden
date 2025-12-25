class_name GUICardFace
extends PanelContainer

const FLIP_ANIMATION_DURATION := 0.1

signal use_card_button_pressed()
signal special_interacted(special:ToolData.Special)
signal special_hovered(special:ToolData.Special, on:bool)
signal _dissolve_finished()
signal _transform_finished()

enum CardState {
	NORMAL,
	HIGHLIGHTED,
	SELECTED,
	UNSELECTED,
	WAITING,
}

const SPECIAL_ICON_SCENE := preload("res://scenes/GUI/controls/buttons/gui_tool_special_icon_button.tscn")
const VALUE_ICON_PREFIX := "res://resources/sprites/GUI/icons/cards/values/icon_"
const EXHAUST_SOUND := preload("res://resources/sounds/SFX/tool_cards/card_exhaust.wav")

const SELECTED_OFFSET := 10.0
const IN_USE_OFFSET := 10.0
const HIGHLIGHTED_OFFSET := 1.0

@onready var _gui_action_list: GUIActionList = %GUIActionList
@onready var _title: Label = %Title
@onready var _card_content: Control = %CardContent
@onready var _interactive_special_container: VBoxContainer = %InteractiveSpecialContainer
@onready var _specials_container: VBoxContainer = %SpecialsContainer
@onready var _cost_icon: TextureRect = %CostIcon
@onready var _rich_text_label: RichTextLabel = %RichTextLabel
@onready var _use_sound: AudioStreamPlayer2D = %UseSound
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _overlay: NinePatchRect = %Overlay
@onready var _gui_use_card_button: GUIUseCardButton = %GUIUseCardButton
@onready var _gui_tool_card_background: GUIToolCardBackground = %GUIToolCardBackground
@onready var _animating_foreground: GUIToolCardBackground = %AnimatingForeground

var card_state:CardState = CardState.NORMAL: set = _set_card_state
var resource_sufficient := false: set = _set_resource_sufficient
var animation_mode := false : set = _set_animation_mode
var disabled:bool = false: set = _set_disabled
var has_outline:bool = false: set = _set_has_outline
var tool_data:ToolData: get = _get_tool_data
var hand_index:int = -1
var is_front:bool = true
var _weak_tool_data:WeakRef = weakref(null)

var _in_hand := false
var _weak_mouse_plant:WeakRef = weakref(null)
var _default_state:CardState = CardState.NORMAL

func _ready() -> void:
	_animation_player.animation_finished.connect(_on_animation_finished)
	_gui_use_card_button.pressed.connect(_on_use_button_pressed)
	_gui_use_card_button.hide()
	_animating_foreground.hide()
	animation_mode = false

func update_with_tool_data(td:ToolData) -> void:
	_weak_tool_data = weakref(td)
	_gui_action_list.update(tool_data.actions, null)
	if !tool_data.get_display_description().is_empty():
		_rich_text_label.text = tool_data.get_display_description()
	if tool_data.get_final_energy_cost() >= 0:
		_cost_icon.texture = load(VALUE_ICON_PREFIX + str(tool_data.get_final_energy_cost()) + ".png")
	else:
		_cost_icon.hide()
	_title.text = tool_data.get_display_name()
	_gui_tool_card_background.update_with_rarity(tool_data.rarity)
	Util.remove_all_children(_specials_container)
	Util.remove_all_children(_interactive_special_container)
	for special in tool_data.specials:
		var special_icon :GUIToolSpecialIconButton = SPECIAL_ICON_SCENE.instantiate()
		if special in ToolData.INTERACTIVE_SPECIALS:
			_interactive_special_container.add_child(special_icon)
		else:
			_specials_container.add_child(special_icon)
		special_icon.special_interacted.connect(func(s:ToolData.Special) -> void: special_interacted.emit(s))
		special_icon.special_hovered.connect(func(s:ToolData.Special, on:bool) -> void: special_hovered.emit(s, on))
		special_icon.update_with_special(special)

	if !td.request_refresh.is_connected(_on_tool_data_refresh):
		td.request_refresh.connect(_on_tool_data_refresh)
	if tool_data.combat_main:
		_on_combat_main_set(tool_data.combat_main)
	else:
		tool_data.combat_main_set.connect(_on_combat_main_set)

func update_mouse_plant(plant:Plant) -> void:
	_gui_action_list.update(tool_data.actions, plant)
	_weak_mouse_plant = weakref(plant)

func play_use_sound() -> void:
	_use_sound.play()

func play_exhaust_animation() -> void:
	_animation_player.play("dissolve")
	GlobalSoundManager.play_sound(EXHAUST_SOUND)
	await _dissolve_finished

func animated_transform(old_rarity:int) -> void:
	has_outline = true
	_animating_foreground.update_with_rarity(old_rarity)
	update_with_tool_data(tool_data)
	_animation_player.play("transform")
	GlobalSoundManager.play_sound(EXHAUST_SOUND)
	await _transform_finished
	has_outline = false

func play_error_shake_animation() -> void:
	await Util.play_error_shake_animation(self, "_container_offset", Vector2.ZERO)

func animate_flip(on:bool) -> void:
	if on :
		visible = true
	_gui_use_card_button.hide()
	var original_pivot_offset := pivot_offset
	pivot_offset = size / 2
	var target_x_scale := 1.0 if on else 0.0
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(self, "scale:x", target_x_scale, FLIP_ANIMATION_DURATION)
	await tween.finished
	pivot_offset = original_pivot_offset
	if on:
		if card_state == CardState.SELECTED && !tool_data.need_select_field:
			_gui_use_card_button.show()
	else:
		visible = false

func _find_card_references() -> Array[String]:
	var card_references:Array[String] = []
	var reference_pairs:Array = DescriptionParser.find_all_reference_pairs(tool_data.description)
	for reference_pair:Array in reference_pairs:
		if reference_pair[0] == "card":
			card_references.append(reference_pair[1])
	return card_references

func _update_for_energy(energy:int) -> void:
	if !tool_data:
		return
	if tool_data.get_final_energy_cost() <= energy:
		resource_sufficient = true
	else:
		resource_sufficient = false

#endregion

#region events

func _on_energy_tracker_value_updated(energy_tracker:ResourcePoint) -> void:
	_update_for_energy(energy_tracker.value)

#endregion

#region setters/getters

func _get_tool_data() -> ToolData:
	return _weak_tool_data.get_ref()

func _set_animation_mode(value:bool) -> void:
	animation_mode = value
	_card_content.visible = !value

func _set_card_state(value:CardState) -> void:
	card_state = value
	match value:
		CardState.NORMAL:
			position = Vector2.ZERO
			has_outline = false
			_overlay.hide()
			_gui_use_card_button.hide()
			z_index = 0
			_default_state = CardState.NORMAL
		CardState.SELECTED:
			position = Vector2.UP * SELECTED_OFFSET
			has_outline = true
			_overlay.hide()
			if tool_data.need_select_field:
				_gui_use_card_button.hide()
			else:
				_gui_use_card_button.show()
			z_index = 1
		CardState.HIGHLIGHTED:
			position = Vector2.UP * HIGHLIGHTED_OFFSET
			has_outline = true
			_overlay.hide()
			_gui_use_card_button.hide()
			z_index = 1
		CardState.UNSELECTED:
			position = Vector2.ZERO
			has_outline = false
			_overlay.show()
			_gui_use_card_button.hide()
			z_index = 0
			_default_state = CardState.UNSELECTED
		CardState.WAITING:
			position = Vector2.UP * SELECTED_OFFSET
			has_outline = true
			_overlay.show()
			_gui_use_card_button.hide()
			z_index = 1

func _set_resource_sufficient(value:bool) -> void:
	resource_sufficient = value
	var sufficient_color := Constants.COST_DEFAULT_COLOR
	if tool_data.get_total_energy_modifier() > 0:
		sufficient_color = Constants.COST_INCREASED_COLOR
	if tool_data.get_total_energy_modifier() < 0:
		sufficient_color = Constants.COST_REDUCED_COLOR
	
	if resource_sufficient:
		_cost_icon.self_modulate = sufficient_color
	else:
		_cost_icon.self_modulate = Constants.RESOURCE_INSUFFICIENT_COLOR
	if disabled:
		_set_disabled(true)

func _set_has_outline(val:bool) -> void:
	has_outline = val
	_gui_tool_card_background.toggle_outline(has_outline, _cost_icon.self_modulate)

func _set_disabled(value:bool) -> void:
	disabled = value
	if value:
		_cost_icon.self_modulate = Constants.CARD_DISABLED_COLOR
	else:
		_set_resource_sufficient(resource_sufficient)
	
#region events

func _on_animation_finished(anim_name:String) -> void:
	if anim_name == "dissolve":
		_dissolve_finished.emit()
	if anim_name == "transform":
		_transform_finished.emit()

func _on_tool_data_refresh() -> void:
	update_with_tool_data(tool_data)

func _on_use_button_pressed() -> void:
	_gui_use_card_button.hide()
	use_card_button_pressed.emit()

func _on_combat_main_set(combat_main:CombatMain) -> void:
	_in_hand = true
	var energy_tracker := combat_main.energy_tracker
	_update_for_energy(energy_tracker.value)
	if !energy_tracker.value_update.is_connected(_on_energy_tracker_value_updated):
		energy_tracker.value_update.connect(_on_energy_tracker_value_updated.bind(energy_tracker))

#endregion
