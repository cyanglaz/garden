class_name PlayerTrinketSilverThimble
extends PlayerTrinket

func _has_hand_size_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_hand_size_hook(_combat_main: CombatMain) -> int:
	return int(data.data[&"draw"])

func _has_start_turn_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_start_turn_hook(combat_main: CombatMain) -> void:
	var discardable := combat_main.tool_manager.discardable_cards()
	if discardable.is_empty():
		return
	var selected := await combat_main.tool_manager.select_cards(
			int(data.data[&"discard"]), discardable)
	if selected.is_empty():
		return
	await combat_main.discard_cards(selected)
