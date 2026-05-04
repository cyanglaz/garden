class_name ToolScriptFreeWill
extends ToolScript

func apply_tool(combat_main: CombatMain, _tool_data: ToolData, secondary_card_datas: Array) -> void:
	if secondary_card_datas.is_empty():
		return
	var selected_card: ToolData = secondary_card_datas[0]
	var changed := false
	if !selected_card.specials.has(ToolData.Special.REVERSIBLE):
		selected_card.specials.append(ToolData.Special.REVERSIBLE)
		changed = true
	if changed:
		selected_card.refresh_ui(combat_main)
	await Util.await_for_tiny_time()

func number_of_secondary_cards_to_select() -> int:
	return 1
