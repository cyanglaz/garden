class_name GUIToolCardButton
extends GUIBasicButton

const SIZE := Vector2(40, 54)

signal use_card_button_pressed()

@onready var front_face: GUICardFace = %FrontFace
@onready var back_face: GUICardFace = %BackFace

@onready var draw_sound: AudioStreamPlayer2D = %DrawSound
@onready var discard_sound: AudioStreamPlayer2D = %DiscardSound
@onready var shuffle_sound: AudioStreamPlayer2D = %ShuffleSound

var current_face:GUICardFace

var mute_interaction_sounds:bool = false
var mouse_disabled:bool = true: set = _set_mouse_disabled
var card_state:GUICardFace.CardState = GUICardFace.CardState.NORMAL: set = _set_card_state, get = _get_card_state
var animation_mode := false : set = _set_animation_mode
var resource_sufficient := false: set = _set_resource_sufficient, get = _get_resource_sufficient
var disabled:bool = false: set = _set_disabled, get = _get_disabled
var has_outline:bool = false: set = _set_has_outline, get = _get_has_outline
var tool_data:ToolData: get = _get_tool_data, set = _set_tool_data
var hand_index:int = -1
var is_front:bool = true: get = _get_is_front, set = _set_is_front
var _card_tooltip_id:String = ""
var _reference_card_tooltip_id:String = ""
var _flipping := false

var _special_tooltip_id:String = ""

func _ready() -> void:
	super._ready()
	current_face = front_face
	mouse_filter = MOUSE_FILTER_IGNORE
	front_face.use_card_button_pressed.connect(func() -> void: use_card_button_pressed.emit())
	back_face.use_card_button_pressed.connect(func() -> void: use_card_button_pressed.emit())
	back_face.hide()
	resized.connect(_on_resized)
	front_face.special_interacted.connect(_on_special_interacted.bind(front_face))
	back_face.special_interacted.connect(_on_special_interacted.bind(back_face))
	front_face.special_hovered.connect(_on_special_hovered.bind(front_face))
	back_face.special_hovered.connect(_on_special_hovered.bind(back_face))
	size = SIZE

func _on_gui_input(event: InputEvent) -> void:
	super._on_gui_input(event)
	if event.is_action_pressed("flip"):
		var should_show_tooltip := !_card_tooltip_id.is_empty()
		toggle_tooltip(false)
		await _animate_flip()
		if should_show_tooltip:
			toggle_tooltip(true)

func update_with_tool_data(td:ToolData) -> void:
	front_face.update_with_tool_data(td)
	if td.back_card:
		assert(td.specials.has(ToolData.Special.FLIP_FRONT), "Card is not a flip front card")
		assert(td.back_card.specials.has(ToolData.Special.FLIP_BACK), "Back card is not a flip back card")
		back_face.update_with_tool_data(td.back_card)

func update_mouse_plant(plant:Plant) -> void:
	front_face.update_mouse_plant(plant)
	if back_face.tool_data:
		back_face.update_mouse_plant(plant)

func play_discard_sound() -> void:
	discard_sound.play()

func play_draw_sound() -> void:
	draw_sound.play()

func play_shuffle_sound() -> void:
	shuffle_sound.play()

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
	if on && tool_data.has_tooltip && _card_tooltip_id.is_empty():
		_card_tooltip_id = Util.get_uuid()
		Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.TOOL_CARD, tool_data, _card_tooltip_id, self, GUITooltip.TooltipPosition.RIGHT))
		_toggle_reference_card_tooltip(true)
	else:
		_toggle_reference_card_tooltip(false)
		Events.request_hide_tooltip.emit(_card_tooltip_id)
		_card_tooltip_id = ""

#region private

func _toggle_reference_card_tooltip(on:bool) -> void:
	if on:
		_reference_card_tooltip_id = Util.get_uuid()
		var reference_card_ids = _find_card_references()
		for reference_card_id in reference_card_ids:
			var reference_card_data := MainDatabase.tool_database.get_data_by_id(reference_card_id)
			Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.REFERENCE_CARD, reference_card_data, _reference_card_tooltip_id, self, GUITooltip.TooltipPosition.LEFT))
	else:
		Events.request_hide_tooltip.emit(_reference_card_tooltip_id)
		_reference_card_tooltip_id = ""

func _find_card_references() -> Array[String]:
	var card_references:Array[String] = []
	var reference_pairs:Array = DescriptionParser.find_all_reference_pairs(tool_data.description)
	for reference_pair:Array in reference_pairs:
		if reference_pair[0] == "card":
			card_references.append(reference_pair[1])
	return card_references

func _play_hover_sound(_volume_db:int = -5) -> void:
	if mute_interaction_sounds:
		return
	if current_face.card_state == GUICardFace.CardState.SELECTED:
		return
	super._play_hover_sound(-5)

func _play_click_sound(_volume_db:int = -5) -> void:
	if mute_interaction_sounds:
		return
	super._play_click_sound(-5)

func _animate_flip() -> void:
	if _flipping:
		return
	if !back_face.tool_data:
		return
	_flipping = true
	await current_face.animate_flip(false)
	var old_face := current_face
	if old_face == front_face:
		current_face = back_face
	else:
		current_face = front_face
	await current_face.animate_flip(true)
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
	animation_mode = value
	if value:
		custom_minimum_size = Vector2.ZERO
		#_card_margin_container.custom_minimum_size = Vector2.ZERO
	else:
		custom_minimum_size = SIZE
	front_face.animation_mode = value
	if back_face.tool_data:
		back_face.animation_mode = value

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
		ToolData.Special.FLIP_FRONT, ToolData.Special.FLIP_BACK:
			_animate_flip()
		_:
			pass

func _on_special_hovered(special:ToolData.Special, on:bool, _face:GUICardFace) -> void:
	if on:
		_special_tooltip_id = Util.get_uuid()
		Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.SPECIALS, [special], _special_tooltip_id, self, GUITooltip.TooltipPosition.RIGHT))
	else:
		Events.request_hide_tooltip.emit(_special_tooltip_id)
		_special_tooltip_id = ""

#region events

func _notification(what:int) -> void:
	if what == NOTIFICATION_PREDELETE:
		toggle_tooltip(false)
#endregion
