class_name PlayerTrinketConservationCoil
extends PlayerTrinket

func _has_start_turn_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_start_turn_hook(combat_main: CombatMain) -> void:
	if data.state == TrinketData.TrinketState.ACTIVE:
		_send_hook_animation_signals()
		combat_main.player.player_status_container.update_player_upgrade(
			"free_move", int(data.data[&"free_move"]), ActionData.OperatorType.INCREASE)
	data.state = TrinketData.TrinketState.ACTIVE
	data.stack = int(data.data[&"cards_played"])

func _has_tool_application_hook(_combat_main: CombatMain, _tool_data: ToolData) -> bool:
	return true

func _handle_tool_application_hook(_combat_main: CombatMain, _tool_data: ToolData) -> void:
	data.stack = max(data.stack - 1, 0)
	if data.stack == 0:
		data.state = TrinketData.TrinketState.NORMAL

func _has_combat_end_hook(_combat_main: CombatMain) -> bool:
	return true

func _handle_combat_end_hook(_combat_main: CombatMain) -> void:
	data.state = TrinketData.TrinketState.NORMAL
	data.stack = 0
