class_name PlayerUpgrade
extends Node2D

signal request_player_upgrade_hook_animation(id:String)
signal request_hook_message_popup(thing_data:ThingData)

var stack:int:set = _set_stack, get = _get_stack
var data:ThingData

func has_prevent_movement_hook() -> bool:
	return _has_prevent_movement_hook()

func toggle_ui_buttons(on:bool) -> void:
	_toggle_ui_buttons(on)

func has_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> bool:
	return _has_tool_application_hook(combat_main, tool_data)

func handle_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> void:
	await _handle_tool_application_hook(combat_main, tool_data)

func has_pre_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> bool:
	return _has_pre_tool_application_hook(combat_main, tool_data)

func handle_pre_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> void:
	await _handle_pre_tool_application_hook(combat_main, tool_data)

func has_activation_hook(combat_main:CombatMain) -> bool:
	return _has_activation_hook(combat_main)

func handle_activation_hook(combat_main:CombatMain) -> void:
	await _handle_activation_hook(combat_main)

func has_card_added_to_hand_hook(tool_datas:Array) -> bool:
	return _has_card_added_to_hand_hook(tool_datas)

func handle_card_added_to_hand_hook(tool_datas:Array, combat_main:CombatMain) -> void:
	await _handle_card_added_to_hand_hook(tool_datas, combat_main)

func has_pool_updated_hook(combat_main:CombatMain, pool:Array) -> bool:
	return _has_pool_updated_hook(combat_main, pool)

func handle_pool_updated_hook(combat_main:CombatMain, pool:Array) -> void:
	await _handle_pool_updated_hook(combat_main, pool)

func has_discard_hook(combat_main:CombatMain, tool_datas:Array) -> bool:
	return _has_discard_hook(combat_main, tool_datas)

func handle_discard_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	await _handle_discard_hook(combat_main, tool_datas)

func has_exhaust_hook(combat_main:CombatMain, tool_datas:Array) -> bool:
	return _has_exhaust_hook(combat_main, tool_datas)

func handle_exhaust_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	await _handle_exhaust_hook(combat_main, tool_datas)

func has_draw_hook(combat_main:CombatMain, tool_datas:Array) -> bool:
	return _has_draw_hook(combat_main, tool_datas)

func handle_draw_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	await _handle_draw_hook(combat_main, tool_datas)

func has_stack_update_hook(combat_main:CombatMain, id:String, diff:int) -> bool:
	return _has_stack_update_hook(combat_main, id, diff)

func handle_stack_update_hook(combat_main:CombatMain, id:String, diff:int) -> void:
	await _handle_stack_update_hook(combat_main, id, diff)

func has_target_plant_water_update_hook(combat_main:CombatMain, plant:Plant, diff:int) -> bool:
	return _has_target_plant_water_update_hook(combat_main, plant, diff)

func handle_target_plant_water_update_hook(combat_main:CombatMain, plant:Plant, diff:int) -> void:
	await _handle_target_plant_water_update_hook(combat_main, plant, diff)

func has_player_move_hook(main_game:CombatMain) -> bool:
	return _has_player_move_hook(main_game)

func handle_player_move_hook(main_game:CombatMain) -> void:
	await _handle_player_move_hook(main_game)

func has_end_turn_hook(combat_main:CombatMain) -> bool:
	return _has_end_turn_hook(combat_main)

func handle_end_turn_hook(combat_main:CombatMain) -> void:
	await _handle_end_turn_hook(combat_main)

func has_start_turn_hook(combat_main:CombatMain) -> bool:
	return _has_start_turn_hook(combat_main)

func handle_start_turn_hook() -> void:
	var request = CombatQueueRequest.new()
	request.front = true
	request.callback = func(combat_main:CombatMain) -> void: _handle_start_turn_hook(combat_main)
	Events.request_combat_queue_push.emit(request)

func has_hand_size_hook(combat_main: CombatMain) -> bool:
	return _has_hand_size_hook(combat_main)

func handle_hand_size_hook(combat_main: CombatMain) -> int:
	return _handle_hand_size_hook(combat_main)

func has_hand_updated_hook(combat_main:CombatMain) -> bool:
	return _has_hand_updated_hook(combat_main)

func handle_hand_updated_hook(combat_main:CombatMain) -> void:
	await _handle_hand_updated_hook(combat_main)

func has_plant_bloom_hook(combat_main:CombatMain) -> bool:
	return _has_plant_bloom_hook(combat_main)

func handle_plant_bloom_hook(combat_main:CombatMain) -> void:
	await _handle_plant_bloom_hook(combat_main)

func has_damage_taken_hook(combat_main:CombatMain, damage:int) -> bool:
	return _has_damage_taken_hook(combat_main, damage)

func handle_damage_taken_hook(damage:int) -> void:
	var request = CombatQueueRequest.new()
	request.front = true
	request.callback = func(combat_main:CombatMain) -> void: _handle_damage_taken_hook(combat_main, damage)
	Events.request_combat_queue_push.emit(request)

func has_combat_end_hook(combat_main:CombatMain) -> bool:
	return _has_combat_end_hook(combat_main)

func handle_combat_end_hook(combat_main:CombatMain) -> void:
	await _handle_combat_end_hook(combat_main)

#region for override

func _has_prevent_movement_hook() -> bool:
	return false

func _toggle_ui_buttons(_on:bool) -> void:
	pass

func _has_tool_application_hook(_combat_main:CombatMain, _tool_data:ToolData) -> bool:
	return false

func _handle_tool_application_hook(_combat_main:CombatMain, _tool_data:ToolData) -> void:
	await Util.await_for_tiny_time()

func _has_pre_tool_application_hook(_combat_main:CombatMain, _tool_data:ToolData) -> bool:
	return false

func _handle_pre_tool_application_hook(_combat_main:CombatMain, _tool_data:ToolData) -> void:
	await Util.await_for_tiny_time()

func _has_activation_hook(_combat_main:CombatMain) -> bool:
	return false

func _handle_activation_hook(_combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

func _has_card_added_to_hand_hook(_tool_datas:Array) -> bool:
	return false

func _handle_card_added_to_hand_hook(_tool_datas:Array, _combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

func _has_pool_updated_hook(_combat_main:CombatMain, _pool:Array) -> bool:
	return false

func _handle_pool_updated_hook(_combat_main:CombatMain, _pool:Array) -> void:
	await Util.await_for_tiny_time()

func _has_discard_hook(_combat_main:CombatMain, _tool_datas:Array) -> bool:
	return false

func _handle_discard_hook(_combat_main:CombatMain, _tool_datas:Array) -> void:
	await Util.await_for_tiny_time()

func _has_exhaust_hook(_combat_main:CombatMain, _tool_datas:Array) -> bool:
	return false

func _handle_exhaust_hook(_combat_main:CombatMain, _tool_datas:Array) -> void:
	await Util.await_for_tiny_time()

func _has_draw_hook(_combat_main:CombatMain, _tool_datas:Array) -> bool:
	return false

func _handle_draw_hook(_combat_main:CombatMain, _tool_datas:Array) -> void:
	await Util.await_for_tiny_time()

func _has_stack_update_hook(_combat_main:CombatMain, _id:String, _diff:int) -> bool:
	return false

func _handle_stack_update_hook(_combat_main:CombatMain, _id:String, _diff:int) -> void:
	await Util.await_for_tiny_time()

func _has_target_plant_water_update_hook(_combat_main:CombatMain, _plant:Plant, _diff:int) -> bool:
	return false

func _handle_target_plant_water_update_hook(_combat_main:CombatMain, _plant:Plant, _diff:int) -> void:
	await Util.await_for_tiny_time()

func _has_player_move_hook(_main_game:CombatMain) -> bool:
	return false

func _handle_player_move_hook(_main_game:CombatMain) -> void:
	await Util.await_for_tiny_time()

func _has_end_turn_hook(_combat_main:CombatMain) -> bool:
	return false

func _handle_end_turn_hook(_combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

func _has_start_turn_hook(_combat_main:CombatMain) -> bool:
	return false

func _handle_start_turn_hook(_combat_main:CombatMain) -> void:
	pass

func _has_hand_size_hook(_combat_main: CombatMain) -> bool:
	return false

func _handle_hand_size_hook(_combat_main: CombatMain) -> int:
	return 0

func _has_hand_updated_hook(_combat_main:CombatMain) -> bool:
	return false

func _handle_hand_updated_hook(_combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

func _has_plant_bloom_hook(_combat_main:CombatMain) -> bool:
	return false

func _handle_plant_bloom_hook(_combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

func _has_damage_taken_hook(_combat_main:CombatMain, _damage:int) -> bool:
	return false

func _handle_damage_taken_hook(_combat_main:CombatMain, _damage:int) -> void:
	pass

func _has_combat_end_hook(_combat_main:CombatMain) -> bool:
	return false

func _handle_combat_end_hook(_combat_main:CombatMain) -> void:
	await Util.await_for_tiny_time()

#endregion

func _send_hook_animation_signals() -> void:
	request_player_upgrade_hook_animation.emit(data.id)
	request_hook_message_popup.emit(data)

func _set_stack(_value:int) -> void:
	assert(false, "must be implemented")

func _get_stack() -> int:
	assert(false, "must be implemented")
	return 0
