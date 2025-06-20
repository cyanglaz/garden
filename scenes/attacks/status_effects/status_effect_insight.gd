class_name StatusEffectInsight
extends StatusEffect

func _has_predraw_effect() -> bool:
	return true

func _on_animation_finished() -> void:
	if character_owner == Singletons.game_main._player:
		Singletons.game_main._player.draw_modifiers["status_effect_insight"] = stack
	handle_finished.emit()

func on_cleared() -> void:
	if character_owner == Singletons.game_main._player:
		Singletons.game_main._player.draw_modifiers.erase("status_effect_insight")
