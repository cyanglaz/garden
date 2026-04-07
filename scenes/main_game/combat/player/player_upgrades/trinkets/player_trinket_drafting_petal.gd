class_name PlayerTrinketDraftingPetal
extends PlayerTrinket

var _last_triggered_turn := -1

func _has_start_turn_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_start_turn_hook(_combat_main: CombatMain) -> void:
	data.state = TrinketData.TrinketState.ACTIVE

func _has_draw_hook(combat_main: CombatMain, _tool_datas: Array) -> bool:
	return combat_main.is_mid_turn and combat_main.day_manager.day != _last_triggered_turn

func _handle_draw_hook(combat_main: CombatMain, _tool_datas: Array) -> void:
	_last_triggered_turn = combat_main.day_manager.day
	_send_hook_animation_signals()
	combat_main.player.player_status_container.update_player_upgrade(
		"momentum",
		int(data.data[&"momentum"]),
		ActionData.OperatorType.INCREASE
	)
	data.state = TrinketData.TrinketState.NORMAL

func _has_combat_end_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_combat_end_hook(_combat_main: CombatMain) -> void:
	data.state = TrinketData.TrinketState.NORMAL