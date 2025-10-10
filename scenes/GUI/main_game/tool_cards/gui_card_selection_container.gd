class_name GUICardSelectionContainer
extends Control

signal secondary_cards_selected(cards:Array)

const GUI_CARD_PLACEMENT_SCENE := preload("res://scenes/GUI/main_game/tool_cards/gui_card_placement.tscn")

@onready var _placement_container: HBoxContainer = %PlacementContainer
@onready var _gui_rich_text_button: GUIRichTextButton = %GUIRichTextButton

var selected_secondary_cards:Array = []

func start_selection(number_of_cards:int) -> void:
	_gui_rich_text_button.hide()
	Util.remove_all_children(_placement_container)
	show()
	for i in number_of_cards:
		var card_placement:GUICardPlacement = GUI_CARD_PLACEMENT_SCENE.instantiate()
		_placement_container.add_child(card_placement)

func is_selected_secondary_card(card:GUIToolCardButton) -> bool:
	return selected_secondary_cards.has(card)

func is_card_selection_full() -> bool:
	assert(selected_secondary_cards.size() <= _placement_container.get_children().size())
	return selected_secondary_cards.size() == _placement_container.get_children().size()

func remove_selected_secondary_card(card:GUIToolCardButton) -> void:
	selected_secondary_cards.erase(card)
	_gui_rich_text_button.hide()

func erase_selected_secondary_cards() -> void:
	Util.remove_all_children(_placement_container)
	selected_secondary_cards.clear()
	_gui_rich_text_button.hide()

func select_secondary_card(card:GUIToolCardButton) -> void:
	# Select a secondary card from hand to placement.
	var card_select_index := selected_secondary_cards.size()
	selected_secondary_cards.append(card)
	var next_position := _placement_container.get_child(card_select_index)
	card.global_position = next_position.global_position
	if selected_secondary_cards.size() == _placement_container.get_children().size():
		_gui_rich_text_button.show()
