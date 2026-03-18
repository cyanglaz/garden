class_name PlayerTrinketBottomlessPocket
extends PlayerTrinket

func _has_start_turn_hook(combat_main: CombatMain) -> bool:
	return combat_main.tool_manager.tool_deck.hand.is_empty()

func _handle_start_turn_hook(combat_main: CombatMain) -> void:
	await combat_main.tool_manager.draw_cards(1, false)
