class_name PlayerUpgradesContainer
extends Node2D

signal player_upgrades_updated()
signal player_upgrade_activated(player_upgrade:PlayerUpgrade)
signal request_player_upgrade_hook_animation(id:String)
signal request_hook_message_popup(thing_data:ThingData)
signal player_upgrade_stack_updated(id:String, diff:int)

var _tool_application_hook_queue:Array = []
var _current_tool_application_hook_index:int = 0
var _card_added_to_hand_hook_queue:Array = []
var _current_card_added_to_hand_hook_index:int = 0
var _activation_hook_queue:Array = []
var _current_activation_hook_index:int = 0
var _discard_hook_queue:Array = []
var _current_discard_hook_index:int = 0
var _draw_hook_queue:Array = []
var _current_draw_hook_index:int = 0
var _stack_update_hook_queue:Array = []
var _current_stack_update_hook_index:int = 0
var _player_move_hook_queue:Array = []
var _current_player_move_hook_index:int = 0
var _end_turn_hook_queue:Array = []
var _current_end_turn_hook_index:int = 0
var _start_turn_hook_queue:Array = []
var _current_start_turn_hook_index:int = 0

func set_player_upgrade(id:String, stack:int) -> void:
	var player_upgrade:PlayerUpgrade = _get_player_upgrade(id)
	if !player_upgrade:
		var player_upgrade_scene:PackedScene = _get_player_upgrade_scene(id)
		player_upgrade = player_upgrade_scene.instantiate()
		add_child(player_upgrade)
		player_upgrade.data = _get_player_upgrade_data(id)
	var previous_stack:int = player_upgrade.stack
	player_upgrade.stack = stack
	if player_upgrade.stack <= 0:
		_remove_player_upgrade(player_upgrade)
	if stack - previous_stack > 0:
		player_upgrade_activated.emit(player_upgrade)
	player_upgrades_updated.emit()
	if stack - previous_stack != 0:
		player_upgrade_stack_updated.emit(id, stack - previous_stack)

func update_player_upgrade(id:String, stack:int, operator_type:ActionData.OperatorType) -> void:
	var current_stack:int = 0
	var player_upgrade:PlayerUpgrade = _get_player_upgrade(id)
	if player_upgrade:
		current_stack = player_upgrade.stack
	var new_stack:int = current_stack
	match operator_type:
		ActionData.OperatorType.INCREASE:
			new_stack = current_stack + stack
		ActionData.OperatorType.DECREASE:
			new_stack = current_stack - stack
		ActionData.OperatorType.EQUAL_TO:
			new_stack = stack
	set_player_upgrade(id, new_stack)

func clear_player_upgrade(id:String) -> void:
	var player_upgrade:PlayerUpgrade = _get_player_upgrade(id)
	if player_upgrade:
		_remove_player_upgrade(player_upgrade)
	player_upgrades_updated.emit()

func clear_all_player_upgrades() -> void:
	for player_upgrade:PlayerUpgrade in get_all_player_upgrades():
		_remove_player_upgrade(player_upgrade)
	player_upgrades_updated.emit()

func get_all_player_upgrades() -> Array:
	return get_children()

func get_player_upgrade_stack(id:String) -> int:
	var player_upgrade:PlayerUpgrade = _get_player_upgrade(id)
	if player_upgrade:
		return player_upgrade.stack
	return 0

func get_player_upgrade(id:String) -> PlayerUpgrade:
	return _get_player_upgrade(id)

#hooks

func handle_prevent_movement_hook() -> bool:
	for player_upgrade:PlayerUpgrade in get_all_player_upgrades():
		if player_upgrade.has_prevent_movement_hook():
			return true
	return false

func handle_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> void:
	var all_player_upgrades:Array = get_all_player_upgrades()
	_tool_application_hook_queue = all_player_upgrades.filter(func(player_upgrade:PlayerUpgrade) -> bool:
		return player_upgrade.has_tool_application_hook(combat_main, tool_data)
	)
	_current_tool_application_hook_index = 0
	await _handle_next_tool_application_hook(combat_main, tool_data)

func _handle_next_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> void:
	if _current_tool_application_hook_index >= _tool_application_hook_queue.size():
		return
	var player_upgrade:PlayerUpgrade = _tool_application_hook_queue[_current_tool_application_hook_index]
	_send_hook_animation_signals(player_upgrade.data)
	await player_upgrade.handle_tool_application_hook(combat_main, tool_data)
	_current_tool_application_hook_index += 1
	await _handle_next_tool_application_hook(combat_main, tool_data)

func handle_card_added_to_hand_hook(tool_datas:Array) -> void:
	var all_player_upgrades:Array = get_all_player_upgrades()
	_card_added_to_hand_hook_queue = all_player_upgrades.filter(func(player_upgrade:PlayerUpgrade) -> bool:
		return player_upgrade.has_card_added_to_hand_hook(tool_datas)
	)
	_current_card_added_to_hand_hook_index = 0
	await _handle_next_card_added_to_hand_hook(tool_datas)

func _handle_next_card_added_to_hand_hook(tool_datas:Array) -> void:
	if _current_card_added_to_hand_hook_index >= _card_added_to_hand_hook_queue.size():
		return
	var player_upgrade:PlayerUpgrade = _card_added_to_hand_hook_queue[_current_card_added_to_hand_hook_index]
	_send_hook_animation_signals(player_upgrade.data)
	await player_upgrade.handle_card_added_to_hand_hook(tool_datas)
	_current_card_added_to_hand_hook_index += 1
	await _handle_next_card_added_to_hand_hook(tool_datas)

func handle_activation_hook(combat_main:CombatMain) -> void:
	var all_player_upgrades:Array = get_all_player_upgrades()
	_activation_hook_queue = all_player_upgrades.filter(func(player_upgrade:PlayerUpgrade) -> bool:
		return player_upgrade.has_activation_hook(combat_main)
	)
	_current_activation_hook_index = 0
	await _handle_next_activation_hook(combat_main)

func _handle_next_activation_hook(combat_main:CombatMain) -> void:
	if _current_activation_hook_index >= _activation_hook_queue.size():
		return
	var player_upgrade:PlayerUpgrade = _activation_hook_queue[_current_activation_hook_index]
	_send_hook_animation_signals(player_upgrade.data)
	await player_upgrade.handle_activation_hook(combat_main)
	_current_activation_hook_index += 1
	await _handle_next_activation_hook(combat_main)

func handle_discard_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	var all_player_upgrades:Array = get_all_player_upgrades()
	_discard_hook_queue = all_player_upgrades.filter(func(player_upgrade:PlayerUpgrade) -> bool:
		return player_upgrade.has_discard_hook(combat_main, tool_datas)
	)
	_current_discard_hook_index = 0
	await _handle_next_discard_hook(combat_main, tool_datas)

func _handle_next_discard_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	if _current_discard_hook_index >= _discard_hook_queue.size():
		return
	var player_upgrade:PlayerUpgrade = _discard_hook_queue[_current_discard_hook_index]
	_send_hook_animation_signals(player_upgrade.data)
	await player_upgrade.handle_discard_hook(combat_main, tool_datas)
	_current_discard_hook_index += 1
	await _handle_next_discard_hook(combat_main, tool_datas)

func handle_draw_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	var all_player_upgrades:Array = get_all_player_upgrades()
	_draw_hook_queue = all_player_upgrades.filter(func(player_upgrade:PlayerUpgrade) -> bool:
		return player_upgrade.has_draw_hook(combat_main, tool_datas)
	)
	_current_draw_hook_index = 0
	await _handle_next_draw_hook(combat_main, tool_datas)

func _handle_next_draw_hook(combat_main:CombatMain, tool_datas:Array) -> void:
	if _current_draw_hook_index >= _draw_hook_queue.size():
		return
	var player_upgrade:PlayerUpgrade = _draw_hook_queue[_current_draw_hook_index]
	_send_hook_animation_signals(player_upgrade.data)
	await player_upgrade.handle_draw_hook(combat_main, tool_datas)
	_current_draw_hook_index += 1
	await _handle_next_draw_hook(combat_main, tool_datas)

func handle_stack_update_hook(combat_main:CombatMain, id:String, diff:int) -> void:
	var all_player_upgrades:Array = get_all_player_upgrades()
	_stack_update_hook_queue = all_player_upgrades.filter(func(player_upgrade:PlayerUpgrade) -> bool:
		return player_upgrade.has_stack_update_hook(combat_main, id, diff)
	)
	_current_stack_update_hook_index = 0
	await _handle_next_stack_update_hook(combat_main, id, diff)

func _handle_next_stack_update_hook(combat_main:CombatMain, id:String, diff:int) -> void:
	if _current_stack_update_hook_index >= _stack_update_hook_queue.size():
		return
	var player_upgrade:PlayerUpgrade = _stack_update_hook_queue[_current_stack_update_hook_index]
	_send_hook_animation_signals(player_upgrade.data)
	await player_upgrade.handle_stack_update_hook(combat_main, id, diff)
	_current_stack_update_hook_index += 1
	await _handle_next_stack_update_hook(combat_main, id, diff)

func handle_player_move_hook(main_game:CombatMain) -> void:
	var all_player_upgrades:Array = get_all_player_upgrades()
	_player_move_hook_queue = all_player_upgrades.filter(func(player_upgrade:PlayerUpgrade) -> bool:
		return player_upgrade.has_player_move_hook(main_game)
	)
	_current_player_move_hook_index = 0
	await _handle_next_player_move_hook(main_game)

func _handle_next_player_move_hook(main_game:CombatMain) -> void:
	if _current_player_move_hook_index >= _player_move_hook_queue.size():
		return
	var player_upgrade:PlayerUpgrade = _player_move_hook_queue[_current_player_move_hook_index]
	_send_hook_animation_signals(player_upgrade.data)
	await player_upgrade.handle_player_move_hook(main_game)
	_current_player_move_hook_index += 1
	await _handle_next_player_move_hook(main_game)

func toggle_ui_buttons(on:bool) -> void:
	for player_upgrade:PlayerUpgrade in get_all_player_upgrades():
		player_upgrade.toggle_ui_buttons(on)

func handle_end_turn_hook(combat_main:CombatMain) -> void:
	var all_player_upgrades:Array = get_all_player_upgrades()
	_end_turn_hook_queue = all_player_upgrades.filter(func(player_upgrade:PlayerUpgrade) -> bool:
		return player_upgrade.has_end_turn_hook(combat_main)
	)
	_current_end_turn_hook_index = 0
	await _handle_next_end_turn_hook(combat_main)

func _handle_next_end_turn_hook(combat_main:CombatMain) -> void:
	if _current_end_turn_hook_index >= _end_turn_hook_queue.size():
		return
	var player_upgrade:PlayerUpgrade = _end_turn_hook_queue[_current_end_turn_hook_index]
	_send_hook_animation_signals(player_upgrade.data)
	await player_upgrade.handle_end_turn_hook(combat_main)
	_current_end_turn_hook_index += 1
	await _handle_next_end_turn_hook(combat_main)

func handle_start_turn_hook(combat_main:CombatMain) -> void:
	var all_player_upgrades:Array = get_all_player_upgrades()
	_start_turn_hook_queue = all_player_upgrades.filter(func(player_upgrade:PlayerUpgrade) -> bool:
		return player_upgrade.has_start_turn_hook(combat_main)
	)
	_current_start_turn_hook_index = 0
	await _handle_next_start_turn_hook(combat_main)

func _handle_next_start_turn_hook(combat_main:CombatMain) -> void:	
	if _current_start_turn_hook_index >= _start_turn_hook_queue.size():
		return
	var player_upgrade:PlayerUpgrade = _start_turn_hook_queue[_current_start_turn_hook_index]
	_send_hook_animation_signals(player_upgrade.data)
	await player_upgrade.handle_start_turn_hook(combat_main)
	_current_start_turn_hook_index += 1
	await _handle_next_start_turn_hook(combat_main)

#private functions

func _remove_player_upgrade(player_upgrade:PlayerUpgrade) -> void:
	remove_child(player_upgrade)
	player_upgrade.queue_free()

func _get_player_upgrade(id:String) -> PlayerUpgrade:
	for player_upgrade:PlayerUpgrade in get_children():
		if player_upgrade.data.id == id:
			return player_upgrade
	return null

func _send_hook_animation_signals(data:ThingData) -> void:
	request_player_upgrade_hook_animation.emit(data.id)
	request_hook_message_popup.emit(data)
	await Util.create_scaled_timer(Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION).timeout

# for override

func _get_player_upgrade_scene(id:String) -> PackedScene:
	assert(false, "Override this function")
	return null

func _get_player_upgrade_data(id:String) -> ThingData:
	assert(false, "Override this function")
	return null
