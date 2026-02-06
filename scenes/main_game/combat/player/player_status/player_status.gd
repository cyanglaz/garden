class_name PlayerStatus
extends Node2D

@warning_ignore("unused_private_class_variable")
var status_data:StatusData
var stack:int:set = _set_stack, get = _get_stack

func has_prevent_movement_hook() -> bool:
	return _has_prevent_movement_hook()

func toggle_ui_buttons(on:bool) -> void:
	_toggle_ui_buttons(on)

func has_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> bool:
	return _has_tool_application_hook(combat_main, tool_data)

func handle_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> void:
	await _handle_tool_application_hook(combat_main, tool_data)

func has_activation_hook(combat_main:CombatMain) -> bool:
	return _has_activation_hook(combat_main)

func handle_activation_hook(combat_main:CombatMain) -> void:
	await _handle_activation_hook(combat_main)

func has_card_added_to_hand_hook(tool_datas:Array) -> bool:
	return _has_card_added_to_hand_hook(tool_datas)

func handle_card_added_to_hand_hook(tool_datas:Array) -> void:
	await _handle_card_added_to_hand_hook(tool_datas)

func has_discard_hook(combat_main:CombatMain, tool_datas:Array) -> bool:
	return _has_discard_hook(combat_main, tool_datas)

func handle_discard_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	await _handle_discard_hook(combat_main, tool_datas)

func has_draw_hook(combat_main:CombatMain, tool_datas:Array) -> bool:
	return _has_draw_hook(combat_main, tool_datas)

func handle_draw_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	await _handle_draw_hook(combat_main, tool_datas)

#region for override

func _has_prevent_movement_hook() -> bool:
	return false

func _toggle_ui_buttons(_on:bool) -> void:
	pass

func _has_tool_application_hook(_combat_main:CombatMain, _tool_data:ToolData) -> bool:
	return false

func _handle_tool_application_hook(_combat_main:CombatMain, _tool_data:ToolData) -> void:
	await Util.await_for_tiny_time()

func _has_activation_hook(_combat_main:CombatMain) -> bool:
	return false

func _handle_activation_hook(_combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

func _has_card_added_to_hand_hook(_tool_datas:Array) -> bool:
	return false

func _handle_card_added_to_hand_hook(_tool_datas:Array) -> void:
	await Util.await_for_tiny_time()

func _has_discard_hook(_combat_main:CombatMain, _tool_datas:Array) -> bool:
	return false

func _handle_discard_hook(_combat_main:CombatMain, _tool_datas:Array) -> void:
	await Util.await_for_tiny_time()

func _has_draw_hook(_combat_main:CombatMain, _tool_datas:Array) -> bool:
	return false

func _handle_draw_hook(_combat_main:CombatMain, _tool_datas:Array) -> void:
	await Util.await_for_tiny_time()

#endregion

func _set_stack(value:int) -> void:
	status_data.stack = value

func _get_stack() -> int:
	return status_data.stack
