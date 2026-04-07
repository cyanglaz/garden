class_name PlayerTrinketTinyPouch
extends PlayerTrinket

func _has_hand_size_hook(combat_main: CombatMain) -> bool:
	return combat_main.day_manager.day == 0

func _handle_hand_size_hook(_combat_main: CombatMain) -> int:
	_send_hook_animation_signals()
	return int(data.data[&"draw"])
