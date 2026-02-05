class_name PlayerStatusContainer
extends Node2D

const PLAYER_STATUS_SCENE_PREFIX := "res://scenes/main_game/combat/player/player_status/player_status_%s.tscn"

signal status_updated()

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
	player_status.stack = stack
	if player_status.stack <= 0:
		_remove_player_status(player_status)
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
