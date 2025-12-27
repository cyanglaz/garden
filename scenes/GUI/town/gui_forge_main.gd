class_name GUIForgeMain
extends Control

signal forge_finished(tool_data:ToolData, front_card_data:ToolData, back_card_data:ToolData, forged_card_global_position:Vector2)

const TOOL_CARD_BUTTON_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")

@onready var title_label: Label = %TitleLabel
@onready var front_card_placeholder: GUICardPlaceHolder = %FrontCardPlaceholder
@onready var back_card_placeholder: GUICardPlaceHolder = %BackCardPlaceholder
@onready var front_card_label: Label = %FrontCardLabel
@onready var back_card_label: Label = %BackCardLabel
@onready var cancel_button: GUIRichTextButton = %CancelButton
@onready var forge_button: GUIRichTextButton = %ForgeButton
@onready var gui_tool_cards_viewer: GUIToolCardsViewer = %GUIToolCardsViewer
@onready var cards_container: Control = %CardsContainer
@onready var gui_forge_animation_container: GUIForgeAnimationContainer = %GUIForgeAnimationContainer

var _card_pool:Array = []
var _selecting_front_card:bool = false
var _front_card:GUIToolCardButton = null
var _back_card:GUIToolCardButton = null

func _ready() -> void:
	forge_button.button_state = GUIBasicButton.ButtonState.DISABLED
	title_label.text = Util.get_localized_string("FORGE_TITLE")
	front_card_label.text = Util.get_localized_string("FORGE_FRONT_CARD_LABEL")
	back_card_label.text = Util.get_localized_string("FORGE_BACK_CARD_LABEL")
	front_card_placeholder.button_enabled = true
	back_card_placeholder.button_enabled = true
	front_card_placeholder.button_pressed.connect(_on_front_card_placeholder_button_pressed)
	back_card_placeholder.button_pressed.connect(_on_back_card_placeholder_button_pressed)
	gui_tool_cards_viewer.hide()
	gui_tool_cards_viewer.card_selected.connect(_on_card_selected)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	forge_button.pressed.connect(_on_forge_button_pressed)
	gui_forge_animation_container.hide()
	gui_forge_animation_container.forged_card_pressed.connect(_on_forged_card_pressed)

func setup_with_card_pool(card_pool:Array) -> void:
	_card_pool = card_pool

func _animate_move_card_to_placeholder(selected_card:GUIToolCardButton, placeholder:GUICardPlaceHolder) -> void:
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(selected_card, "global_position", placeholder.global_position, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func _dismiss() -> void:
	hide()
	_front_card.queue_free()
	_front_card = null
	_back_card.queue_free()
	_back_card = null

func _get_card_pool_for_forge() -> Array:
	var card_pool:Array = _card_pool.duplicate()
	if _front_card != null:
		card_pool.erase(_front_card.tool_data)
	if _back_card != null:
		card_pool.erase(_back_card.tool_data)
	return card_pool

#region events

func _on_front_card_placeholder_button_pressed() -> void:
	_selecting_front_card = true
	if _front_card != null:
		_front_card.queue_free()
		_front_card = null
	gui_tool_cards_viewer.animated_show_with_pool(_get_card_pool_for_forge(), Util.get_localized_string("FORGE_FRONT_CARD_TITLE"))

func _on_back_card_placeholder_button_pressed() -> void:
	_selecting_front_card = false
	if _back_card != null:
		_back_card.queue_free()
		_back_card = null
	gui_tool_cards_viewer.animated_show_with_pool(_get_card_pool_for_forge(), Util.get_localized_string("FORGE_BACK_CARD_TITLE"))

func _on_card_selected(gui_tool_card:GUIToolCardButton) -> void:
	var new_card:GUIToolCardButton
	var tool_data:ToolData = gui_tool_card.tool_data
	new_card = TOOL_CARD_BUTTON_SCENE.instantiate()
	if _selecting_front_card:
		_front_card = new_card
	else:
		_back_card = new_card
	cards_container.add_child(new_card)
	new_card.update_with_tool_data(tool_data)
	new_card.global_position = gui_tool_card.global_position
	new_card.z_index += 1
	gui_tool_cards_viewer.animate_hide()
	if _selecting_front_card:
		_front_card = new_card
		await _animate_move_card_to_placeholder(new_card, front_card_placeholder)
	else:
		_back_card = new_card
		await _animate_move_card_to_placeholder(new_card, back_card_placeholder)
	new_card.z_index -= 1
	new_card.mouse_disabled = false
	new_card.pressed.connect(_on_new_card_pressed.bind(new_card))
	if _front_card && _back_card:
		forge_button.button_state = GUIBasicButton.ButtonState.NORMAL
	else:
		forge_button.button_state = GUIBasicButton.ButtonState.DISABLED

func _on_new_card_pressed(new_card:GUIToolCardButton) -> void:
	if new_card == _front_card:
		_on_front_card_placeholder_button_pressed()
	else:
		_on_back_card_placeholder_button_pressed()

func _on_cancel_button_pressed() -> void:
	_dismiss()

func _on_forge_button_pressed() -> void:
	cancel_button.hide()
	forge_button.hide()
	front_card_placeholder.hide()
	back_card_placeholder.hide()
	front_card_label.hide()
	back_card_label.hide()
	_front_card.hide()
	_back_card.hide()
	title_label.hide()
	assert(_front_card != null, "Front card is null")
	assert(_back_card != null, "Back card is null")
	var front_card_data:ToolData = _front_card.tool_data
	var back_card_data:ToolData = _back_card.tool_data
	assert(_card_pool.has(front_card_data), "Front card is not in pool")
	assert(_card_pool.has(back_card_data), "Back card is not in pool")
	var new_card_front_data:ToolData = front_card_data.get_duplicate()
	var new_card_back_data:ToolData = back_card_data.get_duplicate()
	new_card_front_data.back_card = new_card_back_data
	gui_forge_animation_container.play_animation(_front_card.tool_data, _back_card.tool_data, _front_card.global_position, _back_card.global_position, new_card_front_data)
	#forge_finished.emit(new_card_front_data, front_card_data, back_card_data)
	#_dismiss()

func _on_forged_card_pressed(tool_data:ToolData, card_global_position:Vector2) -> void:
	forge_finished.emit(tool_data, _front_card.tool_data, _back_card.tool_data, card_global_position)
	_dismiss()

#endregion
