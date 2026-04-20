class_name GUIToolCardButton
extends GUIBasicButton

const SIZE := Vector2(40, 54)

signal mouse_entered_card()
signal mouse_exited_card()

@onready var card_face: GUICardFace = %CardFace
@onready var draw_sound: AudioStreamPlayer2D = %DrawSound
@onready var discard_sound: AudioStreamPlayer2D = %DiscardSound
@onready var shuffle_sound: AudioStreamPlayer2D = %ShuffleSound

var mute_interaction_sounds:bool = false
var mouse_disabled:bool = true: set = _set_mouse_disabled
var card_state:GUICardFace.CardState = GUICardFace.CardState.NORMAL: set = _set_card_state, get = _get_card_state
var animation_mode := false : set = _set_animation_mode
var resource_sufficient := false: set = _set_resource_sufficient, get = _get_resource_sufficient
var disabled:bool = false: set = _set_disabled, get = _get_disabled
var has_outline:bool = false: set = _set_has_outline, get = _get_has_outline
var tool_data:ToolData: get = _get_tool_data, set = _set_tool_data
var hand_index:int = -1
var _card_tooltip_id:String = ""
var _reference_card_tooltip_id:String = ""
var _card_hovered:bool = false

var _special_tooltip_id:String = ""
var _weak_combat_main:WeakRef = weakref(null)

func _ready() -> void:
	super._ready()
	mouse_filter = MOUSE_FILTER_IGNORE
	resized.connect(_on_resized)
	card_face.special_hovered.connect(_on_special_hovered.bind(card_face))
	size = SIZE

func update_with_tool_data(td:ToolData, combat_main:CombatMain) -> void:
	_weak_combat_main = weakref(combat_main)
	card_face.update_with_tool_data(td, combat_main)
	if card_face.special_interacted.is_connected(_on_special_interacted.bind(card_face, combat_main)):
		card_face.special_interacted.disconnect(_on_special_interacted.bind(card_face, combat_main))
	card_face.special_interacted.connect(_on_special_interacted.bind(card_face, combat_main))

func play_discard_sound() -> void:
	discard_sound.play()

func play_draw_sound() -> void:
	draw_sound.play()

func play_shuffle_sound() -> void:
	shuffle_sound.play()

func play_use_sound() -> void:
	if mute_interaction_sounds:
		return
	card_face.play_use_sound()

func play_exhaust_animation() -> void:
	await card_face.play_exhaust_animation()

func animated_transform(old_rarity:int) -> void:
	await card_face.animated_transform(old_rarity)

func play_use_animation() -> void:
	card_face.play_use_animation()

func animate_reverse(combat_main:CombatMain) -> void:
	tool_data.reverse(combat_main)

func play_error_shake_animation() -> void:
	await card_face.play_error_shake_animation()

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
	var reference_pairs:Array = DescriptionParser.find_all_reference_pairs(tool_data.get_raw_description())
	for reference_pair:Array in reference_pairs:
		if reference_pair[0] == "card":
			card_references.append(reference_pair[1])
	return card_references

func _play_hover_sound(_volume_db:int = -5) -> void:
	if mute_interaction_sounds:
		return
	if card_face.card_state == GUICardFace.CardState.SELECTED || card_face.card_state == GUICardFace.CardState.WAITING:
		return
	super._play_hover_sound(-5)

func _play_click_sound(_volume_db:int = -5) -> void:
	if mute_interaction_sounds:
		return
	super._play_click_sound(-5)

func _is_mouse_over_card() -> bool:
	if !is_visible_in_tree():
		return false
	var hovered := get_viewport().gui_get_hovered_control()
	if hovered == null:
		return false
	return hovered == self or is_ancestor_of(hovered)

func _refresh_card_hover_state() -> void:
	var over := _is_mouse_over_card()
	if over == _card_hovered:
		return
	_card_hovered = over
	if over:
		Events.update_hovered_data.emit(tool_data)
		if card_state == GUICardFace.CardState.NORMAL:
			card_state = GUICardFace.CardState.HIGHLIGHTED
		mouse_entered_card.emit()
	else:
		Events.update_hovered_data.emit(null)
		if card_state == GUICardFace.CardState.HIGHLIGHTED:
			card_state = GUICardFace.CardState.NORMAL
		mouse_exited_card.emit()
#endregion

#region events

func _on_mouse_entered() -> void:
	super._on_mouse_entered()
	_refresh_card_hover_state.call_deferred()
	await Util.create_scaled_timer(Constants.SECONDARY_TOOLTIP_DELAY).timeout
	if is_queued_for_deletion():
		return
	if is_mouse_hover_secondary_tooltip_enabled():
		toggle_tooltip(true)

func is_mouse_hover_secondary_tooltip_enabled() -> bool:
	return mouse_in && PlayerSettings.setting_data.show_card_tooltip

func _on_mouse_exited() -> void:
	super._on_mouse_exited()
	toggle_tooltip(false)
	_refresh_card_hover_state.call_deferred()

#endregion

#region setters/getters

func _set_mouse_disabled(value:bool) -> void:
	mouse_disabled = value
	if value:
		mouse_filter = MOUSE_FILTER_IGNORE
	else:
		mouse_filter = MOUSE_FILTER_STOP
	card_face.mouse_disabled = value

func _set_tool_data(_value:ToolData) -> void:
	assert(false, "set_tool_data is not allowed, use update_with_tool_data instead")

func _get_tool_data() -> ToolData:
	return card_face.tool_data

func _set_animation_mode(value:bool) -> void:
	animation_mode = value
	if value:
		custom_minimum_size = Vector2.ZERO
	else:
		custom_minimum_size = SIZE
	card_face.animation_mode = value

func _set_card_state(value:GUICardFace.CardState) -> void:
	card_face.card_state = value

func _get_card_state() -> GUICardFace.CardState:
	return card_face.card_state

func _set_resource_sufficient(value:bool) -> void:
	card_face.resource_sufficient = value

func _get_resource_sufficient() -> bool:
	return card_face.resource_sufficient

func _set_has_outline(val:bool) -> void:
	card_face.has_outline = val	

func _get_has_outline() -> bool:
	return card_face.has_outline

func _set_disabled(value:bool) -> void:
	card_face.disabled = value

func _get_disabled() -> bool:
	return card_face.disabled

func _on_resized() -> void:
	card_face.size = size
	
func _on_special_interacted(special:ToolData.Special, _face:GUICardFace, combat_main:CombatMain) -> void:
	match special:
		ToolData.Special.REVERSIBLE:
			animate_reverse(combat_main)
		_:
			pass

func _on_special_hovered(special:ToolData.Special, on:bool, _face:GUICardFace) -> void:
	if on:
		if !_special_tooltip_id.is_empty():
			Events.request_hide_tooltip.emit(_special_tooltip_id)
		_special_tooltip_id = Util.get_uuid()
		Events.request_display_tooltip.emit(TooltipRequest.new(TooltipRequest.TooltipType.SPECIALS, [special], _special_tooltip_id, self, GUITooltip.TooltipPosition.RIGHT))
	else:
		Events.request_hide_tooltip.emit(_special_tooltip_id)
		_special_tooltip_id = ""
	_refresh_card_hover_state.call_deferred()

#region events

func _notification(what:int) -> void:
	if what == NOTIFICATION_PREDELETE:
		toggle_tooltip(false)
#endregion
