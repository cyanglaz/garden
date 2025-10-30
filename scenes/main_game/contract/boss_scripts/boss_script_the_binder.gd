class_name BossScriptBinder
extends BossScript

func _has_hook(hook_type:HookType) -> bool:
	return hook_type == HookType.LEVEL_START

func _handle_hook(hook_type:HookType, combat_main:CombatMain) -> void:
	if hook_type != HookType.LEVEL_START:
		return
	await Util.await_for_tiny_time()
	var combat_modifier:CombatModifier = CombatModifier.new()
	combat_modifier.modifier_type = CombatModifier.ModifierType.CARD_USE_LIMIT
	combat_modifier.modifier_timing = CombatModifier.ModifierTiming.LEVEL
	combat_modifier.modifier_value = boss_data.data["count"] as int
	combat_main.combat_modifier_manager.add_modifier(combat_modifier)
