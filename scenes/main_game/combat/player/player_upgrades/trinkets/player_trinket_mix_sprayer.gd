class_name PlayerTrinketMixSprayer
extends PlayerTrinket

func _has_exhaust_hook(combat_main: CombatMain, _tool_datas: Array) -> bool:
	return not combat_main.tool_manager.tool_deck.hand.is_empty()

func _handle_exhaust_hook(_combat_main: CombatMain, _tool_datas: Array) -> void:
	Events.request_modify_hand_cards.emit(_make_card_free)

func _make_card_free(cards: Array) -> void:
	var random_card: ToolData = Util.unweighted_roll(cards, 1)[0]
	random_card.turn_energy_modifier = -random_card.energy_cost
