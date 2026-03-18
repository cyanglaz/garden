class_name PlayerTrinketTinyPouch
extends PlayerTrinket

func _has_hand_size_hook(combat_main: CombatMain) -> bool:
	return combat_main.day_manager.day == 0

func _handle_hand_size_hook(_combat_main: CombatMain) -> int:
	return int(data.data[&"draw"])
