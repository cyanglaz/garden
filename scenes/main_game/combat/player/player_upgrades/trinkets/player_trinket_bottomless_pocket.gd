class_name PlayerTrinketBottomlessPocket
extends PlayerTrinket

func _has_hand_updated_hook(combat_main:CombatMain) -> bool:
	return combat_main.tool_manager.tool_deck.hand.is_empty()

func _handle_hand_updated_hook(combat_main:CombatMain) -> void:
	_send_hook_animation_signals()
	await combat_main.draw_cards(int(data.data[&"draw"]))
