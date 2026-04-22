class_name PlayerTrinketSilverThimble
extends PlayerTrinket

func _has_hand_size_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_hand_size_hook(_combat_main: CombatMain) -> int:
	_send_hook_animation_signals()
	return int(data.data[&"draw"])

func _has_start_turn_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_start_turn_hook(combat_main: CombatMain) -> void:
	if combat_main.tool_manager.tool_deck.hand.is_empty():
		return
	var selected:Array = await combat_main.tool_manager.select_secondary_cards(
			int(data.data[&"discard"]), null, func(_tool_data:ToolData) -> bool: return true)
	if selected.is_empty():
		return
	await combat_main.discard_cards(selected)
