class_name BossHookManager
extends RefCounted

func apply_boss_hook(boss_data:BossData, hook_type:BossScript.HookType, main_game:MainGame) -> void:
	if boss_data.boss_script.has_hook(hook_type):
		await boss_data.boss_script.handle_hook(hook_type, main_game)	
