class_name ToolScriptFreeWill
extends ToolScript

func apply_tool(combat_main: CombatMain, _tool_data: ToolData, secondary_card_datas: Array) -> void:
	if secondary_card_datas.is_empty():
		return
	var selected_card: ToolData = secondary_card_datas[0]
	var changed := false
	var faces_to_update = [selected_card]
	if selected_card.back_card:
		faces_to_update.append(selected_card.back_card)
	if selected_card.front_card:
		faces_to_update.append(selected_card.front_card)

	for face in faces_to_update:
		if !face.specials.has(ToolData.Special.REVERSIBLE):
			face.specials.append(ToolData.Special.REVERSIBLE)
			changed = true
	if changed:
		selected_card.refresh_ui(combat_main)
	await Util.await_for_tiny_time()

func number_of_secondary_cards_to_select() -> int:
	return 1

func get_card_selection_type() -> ActionData.CardSelectionType:
	return ActionData.CardSelectionType.NON_RESTRICTED
