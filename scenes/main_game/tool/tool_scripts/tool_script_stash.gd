class_name ToolScriptStash
extends ToolScript

func apply_tool(combat_main: CombatMain, _tool_data: ToolData, secondary_card_datas: Array) -> void:
	assert(secondary_card_datas.size() == 1, "ToolScriptStash.apply_tool expected exactly 1 secondary card.")
	if secondary_card_datas.is_empty():
		return
	var selected_card: ToolData = secondary_card_datas[0]
	selected_card.add_specials([ToolData.SpecialEffect.STASHED], combat_main)
	await combat_main.tool_manager.move_hand_card_to_top_of_draw_pile(selected_card, combat_main)

func need_select_field() -> bool:
	return false

func has_field_action() -> bool:
	return false

func number_of_secondary_cards_to_select() -> int:
	return 1

func get_card_selection_type() -> ActionData.CardSelectionType:
	return ActionData.CardSelectionType.NON_RESTRICTED
