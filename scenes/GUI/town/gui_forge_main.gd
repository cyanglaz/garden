class_name GUIForgeMain
extends Control

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

#region events

func _on_front_card_placeholder_button_pressed() -> void:
	_selecting_front_card = true
	if _front_card != null:
		_front_card.queue_free()
		_front_card = null
	gui_tool_cards_viewer.animated_show_with_pool(_card_pool, Util.get_localized_string("FORGE_FRONT_CARD_TITLE"))

func _on_back_card_placeholder_button_pressed() -> void:
	_selecting_front_card = false
	if _back_card != null:
		_back_card.queue_free()
		_back_card = null
	gui_tool_cards_viewer.animated_show_with_pool(_card_pool, Util.get_localized_string("FORGE_BACK_CARD_TITLE"))

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

#endregion
