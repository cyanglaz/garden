class_name GUICardSelectionContainer
extends Control

const TOOL_CARD_PLACEHOLDER_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_card_placeholder.tscn")

const CARD_MOVE_ANIMATION_TIME:float = 0.2

signal _selection_completed()

@onready var _placement_container: HBoxContainer = %PlacementContainer
@onready var _title_label: Label = %TitleLabel
@onready var _gui_check_button: GUIImageButton = %GUICheckButton

var selected_secondary_cards:Array = []
var _number_of_cards_to_select:int = 0

func _ready() -> void:
	_gui_check_button.pressed.connect(_on_check_button_pressed)

func start_selection(number_of_cards:int, selecting_from_cards:Array) -> Array:
	if number_of_cards >= selecting_from_cards.size():
		return selecting_from_cards.duplicate()
	_title_label.text = Util.get_localized_string("SECONDARY_CARD_SELECTION_TITLE")%number_of_cards
	_gui_check_button.button_state = GUIBasicButton.ButtonState.DISABLED
	_number_of_cards_to_select = number_of_cards
	Util.remove_all_children(_placement_container)
	for i in number_of_cards:
		var place_holder:PanelContainer = TOOL_CARD_PLACEHOLDER_SCENE.instantiate()
		place_holder.custom_minimum_size = GUICardFace.SIZE
		_placement_container.add_child(place_holder)
	show()
	await _selection_completed
	return selected_secondary_cards.map(func(card:GUIToolCardButton): return card.tool_data)

func is_selected_secondary_card(card:GUIToolCardButton) -> bool:
	return selected_secondary_cards.has(card)

func is_card_selection_full() -> bool:
	assert(selected_secondary_cards.size() <= _number_of_cards_to_select)
	return selected_secondary_cards.size() == _number_of_cards_to_select

func remove_selected_secondary_card(card:GUIToolCardButton) -> void:
	var index := selected_secondary_cards.find(card)
	assert(index != -1)
	selected_secondary_cards.erase(card)
	_gui_check_button.button_state = GUIBasicButton.ButtonState.DISABLED
	_redisplay_secondary_cards.call_deferred()

func end_selection() -> void:
	Util.remove_all_children(_placement_container)
	selected_secondary_cards.clear()
	_gui_check_button.button_state = GUIBasicButton.ButtonState.DISABLED
	_selection_completed.emit()
	hide()

func select_secondary_card(card:GUIToolCardButton) -> void:
	# Select a secondary card from hand to placement.
	var card_select_index := selected_secondary_cards.size()
	assert(card_select_index < _number_of_cards_to_select)
	selected_secondary_cards.append(card)
	_redisplay_secondary_cards.call_deferred()

func _redisplay_secondary_cards() -> void:
	if selected_secondary_cards.size() == 0:
		return
	var tween := Util.create_scaled_tween(self)
	tween.set_parallel(true)
	for i in selected_secondary_cards.size():
		var card:GUIToolCardButton = selected_secondary_cards[i]
		var place_holder:PanelContainer = _placement_container.get_child(i)
		card.mouse_disabled = true
		tween.tween_property(card, "global_position", place_holder.global_position, CARD_MOVE_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	for card in selected_secondary_cards:	
		card.mouse_disabled = false
	if selected_secondary_cards.size() == _number_of_cards_to_select:
		_gui_check_button.button_state = GUIBasicButton.ButtonState.NORMAL

func _on_check_button_pressed() -> void:
	_selection_completed.emit()
	Util.remove_all_children(_placement_container)
	selected_secondary_cards.clear()
	hide()
