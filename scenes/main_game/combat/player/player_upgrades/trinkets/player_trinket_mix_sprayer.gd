class_name PlayerTrinketMixSprayer
extends PlayerTrinket

func _has_exhaust_hook(combat_main: CombatMain, _tool_datas: Array) -> bool:
	return _get_modifiable_cards(combat_main.tool_manager.tool_deck.hand).size() > 0

func _handle_exhaust_hook(_combat_main: CombatMain, _tool_datas: Array) -> void:
	_send_hook_animation_signals()
	Events.request_modify_hand_cards.emit(_make_card_free)

func _make_card_free(cards: Array) -> void:
	var modifiable_cards := _get_modifiable_cards(cards)
	var random_card: ToolData = Util.unweighted_roll(modifiable_cards, 1)[0]
	random_card.turn_energy_modifier = -random_card.energy_cost

func _get_modifiable_cards(cards: Array) -> Array:
	return cards.filter(func(card: ToolData) -> bool: return card.energy_cost > 0)
