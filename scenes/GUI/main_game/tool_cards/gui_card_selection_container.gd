class_name GUICardSelectionContainer
extends Control

const CARD_MOVE_ANIMATION_TIME:float = 0.2

signal _selection_completed()

@onready var _placement_container: HBoxContainer = %PlacementContainer
@onready var _title_label: Label = %TitleLabel
@onready var _gui_check_button: GUIImageButton = %GUICheckButton

var selected_secondary_cards:Array = []
var _number_of_cards_to_select:int = 0

func _ready() -> void:
	_gui_check_button.pressed.connect(_on_check_button_pressed)

func start_selection(number_of_cards:int) -> Array:
	_title_label.text = Util.get_localized_string("SECONDARY_CARD_SELECTION_TITLE")%number_of_cards
	_gui_check_button.hide()
	_number_of_cards_to_select = number_of_cards
	Util.remove_all_children(_placement_container)
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
	var place_holder:PanelContainer = _placement_container.get_child(index)
	_placement_container.remove_child(place_holder)
	place_holder.queue_free()
	selected_secondary_cards.erase(card)
	_gui_check_button.hide()

func end_selection() -> void:
	Util.remove_all_children(_placement_container)
	selected_secondary_cards.clear()
	_gui_check_button.hide()
	_selection_completed.emit()
	hide()

func select_secondary_card(card:GUIToolCardButton) -> void:
	# Select a secondary card from hand to placement.
	var card_select_index := selected_secondary_cards.size()
	assert(card_select_index < _number_of_cards_to_select)
	selected_secondary_cards.append(card)
	var place_holder:PanelContainer = PanelContainer.new()
	place_holder.custom_minimum_size = GUIToolCardButton.SIZE
	_placement_container.add_child(place_holder)
	_display_secondary_card.call_deferred(card, place_holder)

func _display_secondary_card(card:GUIToolCardButton, place_holder:PanelContainer) -> void:
	var next_position := place_holder.global_position
	card.mouse_disabled = true
	var tween := Util.create_scaled_tween(self)
	tween.tween_property(card, "global_position", next_position, CARD_MOVE_ANIMATION_TIME).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	card.mouse_disabled = false
	if selected_secondary_cards.size() == _number_of_cards_to_select:
		_gui_check_button.show()

func _on_check_button_pressed() -> void:
	_selection_completed.emit()
	Util.remove_all_children(_placement_container)
	selected_secondary_cards.clear()
	hide()
