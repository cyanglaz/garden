class_name GUIEnchantMain
extends CanvasLayer

signal enchant_finished(old_tool_data:ToolData)
signal enchant_card_pressed(tool_data:ToolData, enchant_card_global_position:Vector2)
signal enchant_cancelled()

const TOOL_CARD_BUTTON_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_tool_card_button.tscn")

@onready var title_label: Label = %TitleLabel
@onready var card_place_holder: GUICardPlaceHolder = %CardPlaceHolder
@onready var gui_enchant_icon: GUIEnchantIcon = %GUIEnchantIcon
@onready var cancel_button: GUIRichTextButton = %CancelButton
@onready var enchant_button: GUIRichTextButton = %EnchantButton
@onready var gui_tool_cards_viewer: GUIToolCardsViewer = %GUIToolCardsViewer
@onready var gui_enchant_animation_container: GUIEnchantAnimationContainer = %GUIEnchantAnimationContainer

var _card_pool:Array = []
var _card:GUIToolCardButton = null

var _new_card_data:ToolData = null
var _front_card_data_to_erase:ToolData = null
var _back_card_data_to_erase:ToolData = null
var _enchant_data:EnchantData = null

func _ready() -> void:
	enchant_button.button_state = GUIBasicButton.ButtonState.DISABLED
	title_label.text = Util.get_localized_string("ENCHANT_TITLE")
	gui_tool_cards_viewer.hide()
	gui_tool_cards_viewer.card_selected.connect(_on_card_selected)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	enchant_button.pressed.connect(_on_enchant_button_pressed)
	gui_enchant_animation_container.hide()
	gui_enchant_animation_container.enchant_card_pressed.connect(_on_enchant_card_pressed)
	card_place_holder.button_pressed.connect(_on_card_placeholder_button_pressed)
	card_place_holder.button_hovered.connect(_on_card_placeholder_hovered)

func setup_with_card_pool(card_pool:Array, enchant_data:EnchantData) -> void:
	_card_pool = card_pool
	_new_card_data = null
	_front_card_data_to_erase = null
	_back_card_data_to_erase = null
	_enchant_data = enchant_data
	if _card:
		_card.queue_free()
		_card = null
	title_label.show()
	card_place_holder.show()
	gui_enchant_icon.show()
	cancel_button.show()
	enchant_button.show()
	enchant_button.button_state = GUIBasicButton.ButtonState.DISABLED
	gui_tool_cards_viewer.hide()
	gui_enchant_animation_container.reset()
	gui_enchant_icon.update_with_enchant_data(enchant_data, null)

func _animate_move_card_to_placeholder(selected_card:GUIToolCardButton, placeholder:GUICardPlaceHolder) -> void:
	selected_card.play_discard_sound()
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(selected_card, "global_position", placeholder.global_position, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func _dismiss() -> void:
	hide()
	if _card:
		_card.queue_free()
		_card = null

func _get_card_pool_for_enchant() -> Array:
	var card_pool:Array = _card_pool.duplicate()
	if _card != null:
		card_pool.erase(_card.tool_data)
	return card_pool

#region events

func _on_card_placeholder_button_pressed() -> void:
	if _card != null:
		_card.queue_free()
		_card = null
	gui_tool_cards_viewer.animated_show_with_pool(_get_card_pool_for_enchant(), Util.get_localized_string("FULL_DECK_TITLE"), null)

func _on_card_selected(gui_tool_card:GUIToolCardButton) -> void:
	var new_card:GUIToolCardButton
	var tool_data:ToolData = gui_tool_card.tool_data
	new_card = TOOL_CARD_BUTTON_SCENE.instantiate()
	card_place_holder.add_child(new_card)
	new_card.update_with_tool_data(tool_data, null)
	new_card.global_position = gui_tool_card.global_position
	new_card.z_index += 1
	gui_tool_cards_viewer.animate_hide()
	_card = new_card
	await _animate_move_card_to_placeholder(new_card, card_place_holder)
	new_card.z_index -= 1
	new_card.mouse_disabled = false
	new_card.pressed.connect(_on_new_card_pressed)
	if _card:
		enchant_button.button_state = GUIBasicButton.ButtonState.NORMAL
	else:
		enchant_button.button_state = GUIBasicButton.ButtonState.DISABLED

func _on_new_card_pressed() -> void:
	_on_card_placeholder_button_pressed()

func _on_cancel_button_pressed() -> void:
	_dismiss()
	enchant_cancelled.emit()

func _on_enchant_button_pressed() -> void:
	cancel_button.hide()
	enchant_button.hide()
	card_place_holder.hide()
	gui_enchant_icon.hide()
	_card.hide()
	title_label.hide()
	assert(_card != null, "Card is null")
	var card_data:ToolData = _card.tool_data
	assert(_card_pool.has(card_data), "Card is not in pool")
	_new_card_data = card_data.get_duplicate()
	_new_card_data.enchant_data = _enchant_data.get_duplicate()
	enchant_finished.emit(card_data)
	gui_enchant_animation_container.play_animation(card_data, _enchant_data, _card.global_position, gui_enchant_icon.global_position, _new_card_data)

func _on_enchant_card_pressed(card_global_position:Vector2) -> void:
	enchant_card_pressed.emit(_new_card_data, card_global_position)
	_dismiss()

func _on_card_placeholder_hovered(hovered:bool) -> void:
	if hovered:
		card_place_holder.set_line_color(Constants.COLOR_BLUE_1)
	else:
		card_place_holder.set_line_color(Constants.COLOR_WHITE)

#endregion
