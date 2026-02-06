class_name PlayerStatusContainer
extends Node2D

const PLAYER_STATUS_SCENE_PREFIX := "res://scenes/main_game/combat/player/player_status/player_status_%s.tscn"

signal status_updated()
signal status_activated(player_status:PlayerStatus)
signal request_status_hook_animation(status_id:String)
signal request_hook_message_popup(status_data:StatusData)

var _tool_application_hook_queue:Array = []
var _current_tool_application_hook_index:int = 0
var _card_added_to_hand_hook_queue:Array = []
var _current_card_added_to_hand_hook_index:int = 0
var _activation_hook_queue:Array = []
var _current_activation_hook_index:int = 0
var _discard_hook_queue:Array = []
var _current_discard_hook_index:int = 0

func clear_status_on_turn_end() -> void:
	for player_status:PlayerStatus in get_all_player_statuses():
		if player_status.status_data.reduce_stack_on_turn_end:
			player_status.stack -= 1
			if player_status.stack <= 0:
				_remove_player_status(player_status)
		if player_status.status_data.single_turn:
			_remove_player_status(player_status)
	status_updated.emit()

func set_status(status_id:String, stack:int) -> void:
	var player_status:PlayerStatus = _get_player_status(status_id)
	if !player_status:
		var player_status_scene:PackedScene = load(PLAYER_STATUS_SCENE_PREFIX % status_id)
		player_status = player_status_scene.instantiate()
		add_child(player_status)
		player_status.status_data = MainDatabase.player_status_database.get_data_by_id(status_id)
	var previous_stack:int = player_status.stack
	player_status.stack = stack
	if player_status.stack <= 0:
		_remove_player_status(player_status)
	if stack - previous_stack > 0:
		status_activated.emit(player_status)
	status_updated.emit()

func update_status(status_id:String, stack:int, operator_type:ActionData.OperatorType) -> void:
	var current_stack:int = 0
	var player_status:PlayerStatus = _get_player_status(status_id)
	if player_status:
		current_stack = player_status.stack
	var new_stack:int = current_stack
	match operator_type:
		ActionData.OperatorType.INCREASE:
			new_stack = current_stack + stack
		ActionData.OperatorType.DECREASE:
			new_stack = current_stack - stack
		ActionData.OperatorType.EQUAL_TO:
			new_stack = stack
	set_status(status_id, new_stack)

func clear_status(status_id:String) -> void:
	var player_status:PlayerStatus = _get_player_status(status_id)
	if player_status:
		_remove_player_status(player_status)
	status_updated.emit()

func clear_all_statuses() -> void:
	for player_status:PlayerStatus in get_all_player_statuses():
		_remove_player_status(player_status)
	status_updated.emit()

func clear_single_turn_statuses() -> void:
	for player_status:PlayerStatus in get_all_player_statuses():
		if player_status.status_data.single_turn:
			_remove_player_status(player_status)
	status_updated.emit()

func get_all_player_statuses() -> Array:
	return get_children()

func get_status_stack(status_id:String) -> int:
	var player_status:PlayerStatus = _get_player_status(status_id)
	if player_status:
		return player_status.stack
	return 0

func get_status(status_id:String) -> PlayerStatus:
	return _get_player_status(status_id)

#hooks

func handle_prevent_movement_hook() -> bool:
	for player_status:PlayerStatus in get_all_player_statuses():
		if player_status.has_prevent_movement_hook():
			return true
	return false

func handle_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> void:
	var all_player_statuses:Array = get_all_player_statuses()
	_tool_application_hook_queue = all_player_statuses.filter(func(player_status:PlayerStatus) -> bool:
		return player_status.has_tool_application_hook(combat_main, tool_data)
	)
	_current_tool_application_hook_index = 0
	await _handle_next_tool_application_hook(combat_main, tool_data)

func _handle_next_tool_application_hook(combat_main:CombatMain, tool_data:ToolData) -> void:
	if _current_tool_application_hook_index >= _tool_application_hook_queue.size():
		return
	var player_status:PlayerStatus = _tool_application_hook_queue[_current_tool_application_hook_index]
	_send_hook_animation_signals(player_status.status_data)
	await player_status.handle_tool_application_hook(combat_main, tool_data)
	_current_tool_application_hook_index += 1
	await _handle_next_tool_application_hook(combat_main, tool_data)

func handle_card_added_to_hand_hook(tool_datas:Array) -> void:
	var all_player_statuses:Array = get_all_player_statuses()
	_card_added_to_hand_hook_queue = all_player_statuses.filter(func(player_status:PlayerStatus) -> bool:
		return player_status.has_card_added_to_hand_hook(tool_datas)
	)
	_current_card_added_to_hand_hook_index = 0
	await _handle_next_card_added_to_hand_hook(tool_datas)

func _handle_next_card_added_to_hand_hook(tool_datas:Array) -> void:
	if _current_card_added_to_hand_hook_index >= _card_added_to_hand_hook_queue.size():
		return
	var player_status:PlayerStatus = _card_added_to_hand_hook_queue[_current_card_added_to_hand_hook_index]
	_send_hook_animation_signals(player_status.status_data)
	await player_status.handle_card_added_to_hand_hook(tool_datas)
	_current_card_added_to_hand_hook_index += 1
	await _handle_next_card_added_to_hand_hook(tool_datas)

func handle_activation_hook(combat_main:CombatMain) -> void:
	var all_player_statuses:Array = get_all_player_statuses()
	_activation_hook_queue = all_player_statuses.filter(func(player_status:PlayerStatus) -> bool:
		return player_status.has_activation_hook(combat_main)
	)
	_current_activation_hook_index = 0
	await _handle_next_activation_hook(combat_main)

func _handle_next_activation_hook(combat_main:CombatMain) -> void:
	if _current_activation_hook_index >= _activation_hook_queue.size():
		return
	var player_status:PlayerStatus = _activation_hook_queue[_current_activation_hook_index]
	_send_hook_animation_signals(player_status.status_data)
	await player_status.handle_activation_hook(combat_main)
	_current_activation_hook_index += 1
	await _handle_next_activation_hook(combat_main)

func handle_discard_hook(combat_main:CombatMain, tool_data:ToolData) -> void:
	var all_player_statuses:Array = get_all_player_statuses()
	_discard_hook_queue = all_player_statuses.filter(func(player_status:PlayerStatus) -> bool:
		return player_status.has_discard_hook(combat_main, tool_data)
	)
	_current_discard_hook_index = 0
	await _handle_next_discard_hook(combat_main, tool_data)

func _handle_next_discard_hook(combat_main:CombatMain, tool_data:ToolData) -> void:
	if _current_discard_hook_index >= _discard_hook_queue.size():
		return
	var player_status:PlayerStatus = _discard_hook_queue[_current_discard_hook_index]
	_send_hook_animation_signals(player_status.status_data)
	await player_status.handle_discard_hook(combat_main, tool_data)
	_current_discard_hook_index += 1
	await _handle_next_discard_hook(combat_main, tool_data)

func toggle_ui_buttons(on:bool) -> void:
	for player_status:PlayerStatus in get_all_player_statuses():
		player_status.toggle_ui_buttons(on)

#private functions

func _remove_player_status(player_status:PlayerStatus) -> void:
	remove_child(player_status)
	player_status.queue_free()

func _get_player_status(status_id:String) -> PlayerStatus:
	for player_status:PlayerStatus in get_children():
		if player_status.status_data.id == status_id:
			return player_status
	return null

func _send_hook_animation_signals(status_data:StatusData) -> void:
	request_status_hook_animation.emit(status_data.id)
	request_hook_message_popup.emit(status_data)
	await Util.create_scaled_timer(Constants.FIELD_STATUS_HOOK_ANIMATION_DURATION).timeout
