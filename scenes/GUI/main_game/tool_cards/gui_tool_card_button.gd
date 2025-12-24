class_name GUIToolCardButton
extends GUIBasicButton

const FLIP_ANIMATION_DURATION := 0.1

signal use_card_button_pressed()

@onready var front_face: GUICardFace = %FrontFace
@onready var back_face: GUICardFace = %BackFace

var current_face:GUICardFace

var mute_interaction_sounds:bool = false
var mouse_disabled:bool = true: set = _set_mouse_disabled
var card_state:GUICardFace.CardState = GUICardFace.CardState.NORMAL: set = _set_card_state, get = _get_card_state
var resource_sufficient := false: set = _set_resource_sufficient, get = _get_resource_sufficient
var animation_mode := false : set = _set_animation_mode, get = _get_animation_mode
var disabled:bool = false: set = _set_disabled, get = _get_disabled
var has_outline:bool = false: set = _set_has_outline, get = _get_has_outline
var tool_data:ToolData: get = _get_tool_data, set = _set_tool_data
var hand_index:int = -1
var is_front:bool = true: get = _get_is_front, set = _set_is_front
var _flipping := false

func _ready() -> void:
	super._ready()
	current_face = front_face
	mouse_filter = MOUSE_FILTER_IGNORE
	animation_mode = false
	front_face.use_card_button_pressed.connect(func() -> void: use_card_button_pressed.emit())
	back_face.use_card_button_pressed.connect(func() -> void: use_card_button_pressed.emit())
	resized.connect(_on_resized)
	front_face.special_interacted.connect(_on_special_interacted.bind(front_face))
	back_face.special_interacted.connect(_on_special_interacted.bind(back_face))

func _on_gui_input(event: InputEvent) -> void:
	super._on_gui_input(event)
	if event.is_action_pressed("flip"):
		_animate_flip()

func update_with_tool_data(td:ToolData) -> void:
	front_face.update_with_tool_data(td)
	if td.back_card:
		assert(td.specials.has(ToolData.Special.FLIP), "Card is not a flip card")
		assert(td.back_card.specials.has(ToolData.Special.FLIP), "Back card is not a flip card")
		back_face.update_with_tool_data(td.back_card)
	back_face.hide()

func update_mouse_plant(plant:Plant) -> void:
	front_face.update_mouse_plant(plant)
	if back_face.tool_data:
		back_face.update_mouse_plant(plant)

func play_move_sound() -> void:
	_play_hover_sound()

func play_use_sound() -> void:
	if mute_interaction_sounds:
		return
	current_face.play_use_sound()

func play_exhaust_animation() -> void:
	await current_face.play_exhaust_animation()

func animated_transform(old_rarity:int) -> void:
	await current_face.animated_transform(old_rarity)
	if current_face == back_face:
		front_face.update_with_tool_data(current_face.tool_data.front_card)
	else:
		if current_face.tool_data.back_card:
			back_face.update_with_tool_data(current_face.tool_data.back_card)

func play_error_shake_animation() -> void:
	await current_face.play_error_shake_animation()

func toggle_tooltip(on:bool) -> void:
	if on:
		current_face.toggle_tooltip(on)
	else:
		current_face.toggle_tooltip(on)
		if back_face.tool_data:
			back_face.toggle_tooltip(on)

#region private

func _play_hover_sound() -> void:
	if mute_interaction_sounds:
		return
	if current_face.card_state == GUICardFace.CardState.SELECTED:
		return
	super._play_hover_sound()

func _play_click_sound() -> void:
	if mute_interaction_sounds:
		return
	super._play_click_sound()

func _animate_flip() -> void:
	if _flipping:
		return
	if !back_face.tool_data:
		return
	_flipping = true
	toggle_tooltip(false)
	var original_face_offset := current_face.pivot_offset
	current_face.pivot_offset = Vector2(current_face.size.x/2, 0)
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(current_face, "scale:x", 0, FLIP_ANIMATION_DURATION)
	await tween.finished
	var old_face := current_face
	old_face.hide()
	old_face.pivot_offset = original_face_offset
	if old_face == front_face:
		current_face = back_face
	else:
		current_face = front_face
	current_face.show()
	current_face.pivot_offset = Vector2(current_face.size.x/2, 0)
	current_face.scale.x = 0
	var tween2 := Util.create_scaled_tween(self)
	tween2.tween_property(current_face, "scale:x", 1, FLIP_ANIMATION_DURATION)
	await tween2.finished
	current_face.pivot_offset = original_face_offset
	_flipping = false

#endregion

#region events

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	Events.update_hovered_data.emit(tool_data)
	if card_state == GUICardFace.CardState.NORMAL || card_state == GUICardFace.CardState.UNSELECTED:
		card_state = GUICardFace.CardState.HIGHLIGHTED
	await Util.create_scaled_timer(Constants.SECONDARY_TOOLTIP_DELAY).timeout
	if is_queued_for_deletion():
		return
	if mouse_in:
		toggle_tooltip(true)

func _on_mouse_exited() -> void:
	if card_state == GUICardFace.CardState.HIGHLIGHTED:
		card_state = GUICardFace.CardState.NORMAL
	super._on_mouse_exited()
	Events.update_hovered_data.emit(null)
	toggle_tooltip(false)

#endregion

#region setters/getters

func _set_is_front(_value:bool) -> void:
	assert(false, "set_is_front is not allowed, use flip instead")

func _get_is_front() -> bool:
	return current_face == front_face

func _set_mouse_disabled(value:bool) -> void:
	mouse_disabled = value
	if value:
		mouse_filter = MOUSE_FILTER_IGNORE
	else:
		mouse_filter = MOUSE_FILTER_STOP

func _set_tool_data(_value:ToolData) -> void:
	assert(false, "set_tool_data is not allowed, use update_with_tool_data instead")

func _get_tool_data() -> ToolData:
	return current_face.tool_data

func _set_animation_mode(value:bool) -> void:
	front_face.animation_mode = value
	if back_face.tool_data:
		back_face.animation_mode = value

func _get_animation_mode() -> bool:
	return current_face.animation_mode

func _set_card_state(value:GUICardFace.CardState) -> void:
	front_face.card_state = value
	if back_face.tool_data:
		back_face.card_state = value

func _get_card_state() -> GUICardFace.CardState:
	return current_face.card_state

func _set_resource_sufficient(_value:bool) -> void:
	assert(false, "set_resource_sufficient is not allowed, use update_for_energy instead")

func _get_resource_sufficient() -> bool:
	return current_face.resource_sufficient

func _set_has_outline(val:bool) -> void:
	current_face.has_outline = val	

func _get_has_outline() -> bool:
	return current_face.has_outline

func _set_disabled(value:bool) -> void:
	current_face.disabled = value

func _get_disabled() -> bool:
	return current_face.disabled

func _on_resized() -> void:
	front_face.size = size
	if back_face.tool_data:
		back_face.size = size
	
func _on_special_interacted(special:ToolData.Special, _face:GUICardFace) -> void:
	match special:
		ToolData.Special.FLIP:
			_animate_flip()
		_:
			assert(false, "Special not supported: " + str(special))

#region events

func _notification(what:int) -> void:
	if what == NOTIFICATION_PREDELETE:
		toggle_tooltip(false)
#endregion
