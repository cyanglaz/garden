class_name PlayerTrinketDraftingPetal
extends PlayerTrinket

var _last_triggered_turn := -1

func _has_draw_hook(combat_main: CombatMain, _tool_datas: Array) -> bool:
	return combat_main.is_mid_turn and combat_main.day_manager.day != _last_triggered_turn

func _handle_draw_hook(combat_main: CombatMain, _tool_datas: Array) -> void:
	_last_triggered_turn = combat_main.day_manager.day
	combat_main.player.player_status_container.update_player_upgrade(
		"momentum",
		int(data.data[&"momentum"]),
		ActionData.OperatorType.INCREASE
	)
