class_name BossScriptBinder
extends BossScript

func _has_hook(hook_type:HookType) -> bool:
	return hook_type == HookType.LEVEL_START

func _handle_hook(hook_type:HookType, main_game:MainGame) -> void:
	if hook_type != HookType.LEVEL_START:
		return
	await Util.await_for_tiny_time()
	var game_modifier:GameModifier = GameModifier.new()
	game_modifier.modifier_type = GameModifier.ModifierType.CARD_USE_LIMIT
	game_modifier.modifier_timing = GameModifier.ModifierTiming.LEVEL
	game_modifier.modifier_value = boss_data.data["count"] as int
	main_game.game_modifier_manager.add_modifier(game_modifier)
