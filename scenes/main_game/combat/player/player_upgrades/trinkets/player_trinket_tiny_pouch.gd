class_name PlayerTrinketTinyPouch
extends PlayerTrinket

func _has_start_turn_hook(combat_main: CombatMain) -> bool:
	return combat_main.day_manager.day == 0

func _handle_start_turn_hook(combat_main: CombatMain) -> void:
	assert(combat_main.day_manager.day == 0, "Tiny Pouch should only trigger on turn 1")
	var draw_count: int = int(data.data[&"draw"])
	await combat_main.draw_cards(draw_count)
