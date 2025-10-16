@abstract
class_name ToolScript
extends RefCounted

func apply_tool(_main_game:MainGame, _fields:Array, _field_index:int, _tool_data:ToolData, _secondary_card_datas:Array) -> void:
	await Util.await_for_tiny_time()

func need_select_field() -> bool:
	assert(false, "need_select_field is not implemented")
	return false

func number_of_secondary_cards_to_select() -> int:
	return 0

func secondary_card_selection_filter() -> Callable:
	return func(_tool_data:ToolData) -> bool:
		return true

func handle_post_application_hook(_tool_data:ToolData) -> void:
	await Util.await_for_tiny_time()

func get_card_selection_type() -> ActionData.CardSelectionType:
	if number_of_secondary_cards_to_select() > 0:
		assert(false, "get_card_selection_type must be overridden if number_of_secondary_cards_to_select() > 0")
	return ActionData.CardSelectionType.RESTRICTED
