class_name ToolScriptBreakingRules
extends ToolScript

func apply_tool(combat_main: CombatMain, _tool_data: ToolData, _secondary_card_datas: Array) -> void:
	for card in combat_main.tool_manager.tool_deck.hand:
		if !card.specials.has(ToolData.Special.REVERSIBLE):
			card.specials.append(ToolData.Special.REVERSIBLE)
			card.refresh_ui(combat_main)
	await Util.await_for_tiny_time()
