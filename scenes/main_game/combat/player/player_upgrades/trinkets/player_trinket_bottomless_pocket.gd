class_name PlayerTrinketBottomlessPocket
extends PlayerTrinket

func _has_discard_hook(combat_main:CombatMain, _tool_datas:Array) -> bool:
	return combat_main.tool_manager.tool_deck.hand.is_empty()

func _handle_discard_hook(combat_main:CombatMain, _tool_datas:Array) -> void:
	await combat_main.draw_cards(int(data.data[&"draw"]))

func _has_exhaust_hook(combat_main:CombatMain, _tool_datas:Array) -> bool:
	return combat_main.tool_manager.tool_deck.hand.is_empty()

func _handle_exhaust_hook(combat_main:CombatMain, _tool_datas:Array) -> void:
	await combat_main.draw_cards(int(data.data[&"draw"]))
