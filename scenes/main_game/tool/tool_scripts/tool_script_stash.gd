class_name ToolScriptStash
extends ToolScript

func apply_tool(combat_main: CombatMain, _tool_data: ToolData, secondary_card_datas: Array) -> void:
	var selected_card: ToolData = secondary_card_datas[0]
	selected_card.turn_energy_modifier = -selected_card.energy_cost
	selected_card.request_refresh.emit()
	await combat_main.tool_manager.move_hand_card_to_top_of_draw_pile(selected_card)

func need_select_field() -> bool:
	return false

func has_field_action() -> bool:
	return false

func number_of_secondary_cards_to_select() -> int:
	return 1

func get_card_selection_type() -> ActionData.CardSelectionType:
	return ActionData.CardSelectionType.RESTRICTED
