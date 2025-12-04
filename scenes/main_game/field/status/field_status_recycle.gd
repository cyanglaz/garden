class_name FieldStatusRecycle
extends FieldStatus

signal _adding_all_cards_finished()

var _card_added := -1

func _has_add_water_hook(plant:Plant) -> bool:
	return plant != null

func _handle_add_water_hook(plant:Plant) -> void:
	var tool_data:ToolData = MainDatabase.tool_database.get_data_by_id("graywater").get_duplicate()
	var from_position:Vector2 = Util.get_node_canvas_position(plant) - GUIToolCardButton.SIZE / 2
	var number_of_cards := stack
	var cards:Array[ToolData] = []
	for i in number_of_cards:
		var tool_data_to_add:ToolData = tool_data.get_duplicate()
		tool_data_to_add.adding_to_deck_finished.connect(_on_card_added_to_deck_finished)
		cards.append(tool_data_to_add)
	_card_added = number_of_cards
	Events.request_add_tools_to_hand.emit(cards, from_position, true)
	await _adding_all_cards_finished

func _on_card_added_to_deck_finished() -> void:
	_card_added -= 1
	if _card_added == 0:
		_adding_all_cards_finished.emit()
