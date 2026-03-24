class_name PlayerTrinketMixSprayer
extends PlayerTrinket

func _has_exhaust_hook(_combat_main: CombatMain, _tool_datas: Array) -> bool:
	return true

func _handle_exhaust_hook(combat_main: CombatMain, _tool_datas: Array) -> void:
	var hand := combat_main.tool_manager.tool_deck.hand
	if hand.is_empty():
		return
	var random_card: ToolData = Util.unweighted_roll(hand, 1)[0]
	random_card.turn_energy_modifier = -random_card.energy_cost
	combat_main.tool_manager.refresh_ui()
